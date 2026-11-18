import UserEntryModel from '../models/UserEntryModel.js';

// Синхронизация личных данных приложения (дневник питания, вода, избранное).
// Сервер хранит записи как есть и не разбирает `data` — формат определяет
// приложение. Протокол как у /app/sync каталога: клиент присылает изменения
// пачкой и забирает дельту по `since` (syncedAt из прошлого ответа).

export const ENTRY_KINDS = ['food_log', 'water', 'favorite', 'fast', 'setting'];
const MAX_BATCH = 500;
const MAX_ID_LENGTH = 100;
const MAX_DATA_BYTES = 8 * 1024;
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
const SYNC_OVERLAP_SECONDS = 5;

function validateRef(item, index) {
  if (!item || typeof item !== 'object') throw new Error(`item ${index}: must be an object`);
  if (!ENTRY_KINDS.includes(item.kind)) throw new Error(`item ${index}: kind must be one of ${ENTRY_KINDS.join(', ')}`);
  if (typeof item.id !== 'string' || !item.id || item.id.length > MAX_ID_LENGTH) throw new Error(`item ${index}: id must be a non-empty string up to ${MAX_ID_LENGTH} chars`);
}

function normalizeUpsert(item, index) {
  validateRef(item, index);
  const personId = item.personId ?? null;
  if (personId !== null && (typeof personId !== 'string' || personId.length > MAX_ID_LENGTH)) throw new Error(`item ${index}: personId must be a string or null`);
  const date = item.date ?? null;
  if (date !== null && (typeof date !== 'string' || !DATE_RE.test(date) || Number.isNaN(Date.parse(date)))) throw new Error(`item ${index}: date must be YYYY-MM-DD or null`);
  const data = item.data ?? {};
  if (typeof data !== 'object' || Array.isArray(data)) throw new Error(`item ${index}: data must be an object`);
  if (Buffer.byteLength(JSON.stringify(data)) > MAX_DATA_BYTES) throw new Error(`item ${index}: data is larger than ${MAX_DATA_BYTES} bytes`);
  return { kind: item.kind, id: item.id, personId, date, data };
}

function toClient(row) {
  return {
    kind: row.kind,
    id: row.id,
    personId: row.person_id,
    date: row.date,
    data: row.data,
    updatedAt: row.utime
  };
}

export default class UserEntryService {
  // { entries: [...живые изменённые], deleted: [{ kind, id }], syncedAt }
  // syncedAt — время БД (не часы Node) ДО выборки, минус запас: запись,
  // которая сохранялась параллельно с этим запросом, попадёт в следующую
  // дельту, а не потеряется между ними. Повторно отданные записи безвредны —
  // клиент применяет их идемпотентно.
  static async getChanges(userId, since) {
    let sinceDate = null;
    if (since) {
      sinceDate = new Date(since);
      if (Number.isNaN(sinceDate.getTime())) throw new Error('since must be an ISO date');
    }
    const syncedAt = await UserEntryModel.syncPoint(SYNC_OVERLAP_SECONDS);
    const rows = await UserEntryModel.getChanged(userId, sinceDate);
    return {
      entries: rows.filter(row => !row.deleted_at).map(toClient),
      deleted: rows.filter(row => row.deleted_at).map(row => ({ kind: row.kind, id: row.id })),
      syncedAt
    };
  }

  // body: { upserts: [{ kind, id, personId?, date?, data }], deletes: [{ kind, id }] }
  // Всё проверяется до записи: ошибка в одном элементе — 400, ничего не сохранено.
  // Вставки/обновления — одним SQL-оператором (атомарно), удаления — вторым.
  static async applyBatch(userId, body) {
    const upserts = body?.upserts ?? [];
    const deletes = body?.deletes ?? [];
    if (!Array.isArray(upserts) || !Array.isArray(deletes)) throw new Error('upserts and deletes must be arrays');
    if (upserts.length + deletes.length > MAX_BATCH) throw new Error(`at most ${MAX_BATCH} items per batch`);
    const normalized = upserts.map(normalizeUpsert);
    deletes.forEach((item, index) => validateRef(item, index));

    // Последнее изменение одного и того же ключа в пачке выигрывает; удаление
    // в той же пачке отменяет запись.
    const keyOf = item => `${item.kind}\u0000${item.id}`;
    const deleteKeys = new Set(deletes.map(keyOf));
    const upsertByKey = new Map();
    for (const item of normalized) if (!deleteKeys.has(keyOf(item))) upsertByKey.set(keyOf(item), item);
    const uniqueDeletes = [...new Map(deletes.map(item => [keyOf(item), { kind: item.kind, id: item.id }])).values()];

    await UserEntryModel.upsertMany(userId, [...upsertByKey.values()]);
    await UserEntryModel.softDeleteMany(userId, uniqueDeletes);
    return { upserted: normalized.length, deleted: deletes.length };
  }
}
