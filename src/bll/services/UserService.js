import UserModel from '../models/UserModel.js';
import { ROLES } from '../utils/const.js';

// Поля анкеты (см. install/steps/1.sql), изменения которых пишутся в
// preferences.history.
const HISTORY_FIELDS = [
  'sex', 'age', 'height_cm', 'weight_kg', 'target_weight_kg',
  'activity_level', 'goal_type', 'manual_calorie_target', 'manual_macro_split'
];
const NUMERIC_FIELDS = ['age', 'height_cm', 'weight_kg', 'target_weight_kg', 'manual_calorie_target'];

// numeric-колонки pg отдаёт строкой ("80.0"), клиент шлёт числом — приводим к числу,
// чтобы 80 и "80.0" не считались изменением.
function normalizeValue(key, value) {
  if (value === undefined || value === null || value === '') return null;
  return NUMERIC_FIELDS.includes(key) ? Number(value) : value;
}

// jsonb в Postgres не сохраняет порядок ключей — сравниваем канонически.
function canonical(value) {
  if (Array.isArray(value)) return value.map(canonical);
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.keys(value).sort().map(k => [k, canonical(value[k])]));
  }
  return value;
}

// Члены семьи: профиль хранится как есть (формат приложения, camelCase), а
// историю изменений ключевых полей сервер считает сам.
const MAX_FAMILY_MEMBERS = 20;
const MEMBER_HISTORY_KEYS = ['sex', 'age', 'heightCm', 'weightKg', 'targetWeightKg', 'activityLevel', 'goalType'];

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function memberSnapshot(profile) {
  const source = { ...profile, goalType: profile?.goal?.type };
  const snapshot = {};
  for (const key of MEMBER_HISTORY_KEYS) {
    const value = source[key];
    snapshot[key] = value === undefined || value === null || value === '' ? null : value;
  }
  return snapshot;
}

function normalizeFamilyMembers(list, existingMembers, now) {
  if (!Array.isArray(list)) throw new Error('familyMembers must be an array');
  if (list.length > MAX_FAMILY_MEMBERS) throw new Error(`familyMembers: at most ${MAX_FAMILY_MEMBERS} members`);

  const seen = new Set();
  return list.map(member => {
    if (!isPlainObject(member) || typeof member.id !== 'string' || !member.id || !isPlainObject(member.profile)) {
      throw new Error('familyMembers: each member needs a string id and a profile object');
    }
    if (seen.has(member.id)) throw new Error('familyMembers: duplicate id');
    seen.add(member.id);

    // history ведёт только сервер — присланная клиентом игнорируется.
    const previous = existingMembers.find(m => m.id === member.id);
    const previousSnapshot = previous ? memberSnapshot(previous.profile) : {};
    const nextSnapshot = memberSnapshot(member.profile);
    const history = { ...(previous?.history || {}) };
    for (const key of MEMBER_HISTORY_KEYS) {
      const before = previousSnapshot[key] ?? null;
      if (JSON.stringify(canonical(nextSnapshot[key])) === JSON.stringify(canonical(before))) continue;
      history[key] = [...(history[key] || []), { value: nextSnapshot[key], ctime: now }];
    }
    return { id: member.id, profile: member.profile, history };
  });
}

const ASSIGNABLE_ROLES = [ROLES.SUPER_ADMIN, ROLES.ADMIN, ROLES.USER];

export default class UserService {
  static async getById(id) {
    const user = await UserModel.getUserById(id);
    if (!user) throw new Error('User not found');
    return user;
  }

  static async getAll() {
    return UserModel.getAll();
  }

  // Доступ ограничен на уровне роута (auth([ROLES.SUPER_ADMIN]) в
  // routes/v1/users) — сюда попадают только запросы от super_admin. Менять
  // свою собственную роль нельзя — иначе можно случайно разжаловать себя
  // без другого super_admin, способного вернуть доступ.
  static async setRole(actingUserId, targetUserId, role) {
    if (!ASSIGNABLE_ROLES.includes(role)) throw new Error('invalid role');
    if (actingUserId === targetUserId) throw new Error('cannot change your own role');

    const user = await UserService.getById(targetUserId);
    user.f.role = role;
    user.f.utime = new Date();
    await user.save();

    return user;
  }

  static async updateProfile(userId, updates) {
    const user = await UserModel.getUserById(userId);
    if (!user) throw new Error('User not found');

    const allowed = ['name', 'surname', ...HISTORY_FIELDS, 'preferences'];

    const previous = {};
    for (const key of HISTORY_FIELDS) previous[key] = user.f[key];
    const existingPreferences = user.f.preferences || {};
    const history = existingPreferences.history && typeof existingPreferences.history === 'object' ? existingPreferences.history : {};

    for (const key of allowed) {
      if (key === 'preferences') continue;
      if (updates[key] !== undefined) user.f[key] = updates[key];
    }

    // preferences заменяются целиком (как и раньше), но history ведёт только
    // сервер — иначе клиент, присылая свою копию preferences, затёр бы историю.
    const now = new Date().toISOString();
    const existingMembers = Array.isArray(existingPreferences.familyMembers) ? existingPreferences.familyMembers : [];
    let familyMembers = existingMembers;
    let preferences = existingPreferences;
    if (updates.preferences !== undefined) {
      if (updates.preferences === null || typeof updates.preferences !== 'object' || Array.isArray(updates.preferences)) {
        throw new Error('preferences must be an object');
      }
      preferences = { ...updates.preferences };
      // familyMembers меняются только если ключ прислан — клиент, не знающий о
      // семье, не должен случайно стереть её, заменяя preferences целиком.
      if ('familyMembers' in updates.preferences) {
        familyMembers = normalizeFamilyMembers(updates.preferences.familyMembers, existingMembers, now);
      }
    }

    // В историю пишем только реальное изменение поля — повторная отправка тех
    // же значений (анкета целиком уходит при каждом сохранении) не плодит записи.
    const nextHistory = { ...history };
    for (const key of HISTORY_FIELDS) {
      const value = normalizeValue(key, user.f[key]);
      if (JSON.stringify(canonical(value)) === JSON.stringify(canonical(normalizeValue(key, previous[key])))) continue;
      nextHistory[key] = [...(history[key] || []), { value, ctime: now }];
    }
    user.f.preferences = { ...preferences, history: nextHistory };
    if (familyMembers.length > 0 || (updates.preferences && 'familyMembers' in updates.preferences)) {
      user.f.preferences.familyMembers = familyMembers;
    } else {
      delete user.f.preferences.familyMembers;
    }

    user.f.utime = new Date();
    await user.save();

    return user;
  }

  // Вся история или одного поля (?field=weight_kg): { field: [{ value, ctime }] } / [{ value, ctime }]
  static async getHistory(userId, field) {
    const user = await UserService.getById(userId);
    const history = user.f.preferences?.history || {};
    if (!field) return history;
    if (!HISTORY_FIELDS.includes(field)) throw new Error('unknown field');
    return history[field] || [];
  }

  static async getWeightHistory(userId) {
    const items = await UserService.getHistory(userId, 'weight_kg');
    return items.map(i => ({ weight_kg: i.value, ctime: i.ctime }));
  }
}
