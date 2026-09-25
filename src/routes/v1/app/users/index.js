import UserController from '../../../../controllers/user.js'
import auth from '../../../../hooks/preHendler.js';

// Для мобильного приложения — только свой профиль. Список пользователей и
// смена ролей — см. routes/v1/admin/users (только super_admin).
export default async function appUserRoutes(fastify, _options) {
    fastify.get('/me', {preHandler: [auth()]}, UserController.getMe)
    fastify.put('/me', {preHandler: [auth()]}, UserController.updateMe)
    fastify.get('/me/history', {preHandler: [auth()]}, UserController.getHistory)
    fastify.get('/me/weight-history', {preHandler: [auth()]}, UserController.getWeightHistory)
}
