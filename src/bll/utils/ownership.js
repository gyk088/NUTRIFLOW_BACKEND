import UserModel from '../models/UserModel.js';

// Общие правила для пользовательских ингредиентов/рецептов (см.
// install/steps/23.sql): запись видна всем, если она в каталоге (is_public),
// иначе — только своему автору.
export function isVisibleTo(row, userId) {
  return row.f.is_public || (!!userId && row.f.user_id === userId);
}

// Пользователь может менять/удалять только свои ещё личные записи — после
// добавления в каталог запись принадлежит каталогу и правится в админке.
export function assertOwnPrivate(row, userId, entityName) {
  if (!row || row.f.user_id !== userId) throw new NotFoundError(`${entityName} not found`);
  if (row.f.is_public) throw new Error(`${entityName} is already in the shared catalog and can no longer be changed`);
}

export class NotFoundError extends Error {}

function authorOf(user) {
  return { id: user.f.id, name: user.f.name, surname: user.f.surname, email: user.f.email };
}

// Map userId -> { id, name, surname, email } для подписи "кто создал" в админке.
export async function loadAuthors(rows) {
  const ids = [...new Set(rows.map(r => r.f.user_id).filter(Boolean))];
  const users = await UserModel.getByIds(ids);
  return new Map(users.map(u => [u.f.id, authorOf(u)]));
}

export async function loadAuthor(userId) {
  if (!userId) return null;
  const user = await UserModel.getUserById(userId);
  return user ? authorOf(user) : null;
}

// Числа от клиента приложения: только конечные и неотрицательные.
export function toNonNegativeNumber(value, field) {
  const number = Number(value);
  if (value === null || value === '' || !Number.isFinite(number) || number < 0) {
    throw new Error(`${field} must be a non-negative number`);
  }
  return number;
}
