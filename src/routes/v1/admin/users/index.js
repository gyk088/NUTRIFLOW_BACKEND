import UserController from '../../../../controllers/user.js'
import auth from '../../../../hooks/preHendler.js';
import { ROLES } from '../../../../bll/utils/const.js';

// Управление пользователями — только для super_admin. Свой профиль — см. routes/v1/app/users.
export default async function adminUserRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth([ROLES.SUPER_ADMIN])]}, UserController.getAll)
    fastify.put('/:id/role', {preHandler: [auth([ROLES.SUPER_ADMIN])]}, UserController.setRole)
}
