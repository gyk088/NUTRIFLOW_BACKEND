import AuthService from '../bll/services/AuthService.js';

// preHandler-хук авторизации. Использование: {preHandler: [auth()]} — любой
// авторизованный пользователь, {preHandler: [auth(['admin'])]} — только роль admin.
export default function auth (rolesArray) {
  return async function(request, reply) {
    try {
      const token = request.headers?.authorization?.replace('Bearer ', '');
      if (!token) {
        throw new Error('No token was sent');
      }

      const result = await AuthService.loginByToken(
        token,
        request.ip,
        request.headers['user-agent'],
        request.headers['x-fcm']
      );

      if (!result) {
        throw new Error('Authentication failed! No such user');
      }

      const { user, impersonatedBy } = result;

      if (rolesArray && rolesArray?.length && !rolesArray.includes(user.f.role)) {
        // Аутентификация прошла успешно, но роли не хватает — это 403, а не 401.
        reply.code(403).send(new Error(`No access! User: ${user.f.name}, ${user.f.role}`));
        return;
      }
      request.user = user;
      request.impersonatedBy = impersonatedBy;
    } catch (error) {
      reply.code(401).send(error);
    }
  }
}

// Как auth(), но никогда не отвечает 401 — без токена или с недействительным
// токеном request.user просто остаётся null (гостевой доступ). Для роутов,
// которые отдают урезанные данные анонимам (см. /app/sync).
export function optionalAuth () {
  return async function(request, _reply) {
    const token = request.headers?.authorization?.replace('Bearer ', '');
    if (!token) {
      request.user = null;
      return;
    }

    try {
      const result = await AuthService.loginByToken(
        token,
        request.ip,
        request.headers['user-agent'],
        request.headers['x-fcm']
      );
      request.user = result?.user ?? null;
      request.impersonatedBy = result?.impersonatedBy;
    } catch {
      request.user = null;
    }
  }
}
