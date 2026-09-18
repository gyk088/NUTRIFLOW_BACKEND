import UserController from '../../../controllers/user.js'
import auth from '../../../hooks/preHendler.js';
import { ROLES } from '../../../bll/utils/const.js';

export default async function userRoutes(fastify, _options) {
    fastify.get('/me', {preHandler: [auth()]}, UserController.getMe)
    fastify.put('/me', {preHandler: [auth()]}, UserController.updateMe)
    fastify.get('/', {preHandler: [auth([ROLES.SUPER_ADMIN])]}, UserController.getAll)
    fastify.put('/:id/role', {preHandler: [auth([ROLES.SUPER_ADMIN])]}, UserController.setRole)
}
