import UserController from '../../../controllers/user.js'
import auth from '../../../hooks/preHendler.js';

export default async function userRoutes(fastify, _options) {
    fastify.get('/me', {preHandler: [auth()]}, UserController.getMe)
    fastify.put('/me', {preHandler: [auth()]}, UserController.updateMe)
}
