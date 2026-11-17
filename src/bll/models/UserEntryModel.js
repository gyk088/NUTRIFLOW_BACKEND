import PgObject from 'pgobject';

// Личные данные из приложения: дневник питания, вода, избранные рецепты
// (install/steps/24.sql). Пишется и читается пачками через UserEntryService,
// поэтому здесь только SQL — upsert/мягкое удаление и выборка дельты.
export default class UserEntryModel extends PgObject {
  static get schema() {
    return {
      user_id: { pk: true, required: true },
      kind: { pk: true, required: true },
      id: { pk: true, required: true },
      person_id: {},
      date: {},
      data: {},
      utime: {},
      deleted_at: {}
    };
  }

  static get table() {
    return 'user_entry';
  }

  // Момент синхронизации по часам БД (utime ставит now() БД), сдвинутый назад на overlapSeconds.
  static async syncPoint(overlapSeconds) {
    const result = await UserEntryModel.query(`SELECT now() - make_interval(secs => $1::double precision) AS at`, [overlapSeconds]);
    return new Date(result.rows[0].at).toISOString();
  }

  // Записи, изменённые после `since` (или все живые, если since = null).
  // Дата отдаётся строкой YYYY-MM-DD, без сдвига часового пояса.
  static async getChanged(userId, since) {
    const result = since
      ? await UserEntryModel.query(
        `SELECT kind, id, person_id, to_char(date, 'YYYY-MM-DD') AS date, data, utime, deleted_at
         FROM user_entry WHERE user_id = $1 AND utime > $2 ORDER BY utime`,
        [userId, since]
      )
      : await UserEntryModel.query(
        `SELECT kind, id, person_id, to_char(date, 'YYYY-MM-DD') AS date, data, utime, deleted_at
         FROM user_entry WHERE user_id = $1 AND deleted_at IS NULL ORDER BY utime`,
        [userId]
      );
    return result.rows;
  }

  // Все записи пачки одним оператором — атомарно (Pool не даёт держать
  // транзакцию на нескольких query()). items: [{ kind, id, personId, date, data }],
  // ключи (kind, id) в пачке уникальны — дубликаты ON CONFLICT не допускает.
  static async upsertMany(userId, items) {
    if (!items.length) return;
    return UserEntryModel.query(
      `INSERT INTO user_entry (user_id, kind, id, person_id, date, data, utime, deleted_at)
       SELECT $1, x.kind, x.id, x."personId", x.date::date, COALESCE(x.data, '{}'::jsonb), now(), NULL
       FROM jsonb_to_recordset($2::jsonb) AS x(kind text, id text, "personId" text, date text, data jsonb)
       ON CONFLICT (user_id, kind, id) DO UPDATE
       SET person_id = EXCLUDED.person_id, date = EXCLUDED.date, data = EXCLUDED.data, utime = now(), deleted_at = NULL`,
      [userId, JSON.stringify(items)]
    );
  }

  // Мягкое удаление: строка остаётся, чтобы другие устройства узнали об
  // удалении из дельты. Удаление неизвестной записи — не ошибка.
  static async softDeleteMany(userId, refs) {
    if (!refs.length) return;
    return UserEntryModel.query(
      `UPDATE user_entry e SET deleted_at = now(), utime = now(), data = '{}'::jsonb
       FROM jsonb_to_recordset($2::jsonb) AS x(kind text, id text)
       WHERE e.user_id = $1 AND e.kind = x.kind AND e.id = x.id AND e.deleted_at IS NULL`,
      [userId, JSON.stringify(refs)]
    );
  }
}
