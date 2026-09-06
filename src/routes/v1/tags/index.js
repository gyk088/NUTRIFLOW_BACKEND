import TagController from '../../../controllers/tag.js'
import auth from '../../../hooks/preHendler.js';
import { ROLES } from '../../../bll/utils/const.js';

export default async function tagRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth([ROLES.ADMIN])]}, TagController.create);
    fastify.get('/', {preHandler: [auth()]}, TagController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, TagController.getById);
    fastify.put('/:id', {preHandler: [auth([ROLES.ADMIN])]}, TagController.update);
    fastify.delete('/:id', {preHandler: [auth([ROLES.ADMIN])]}, TagController.remove);
}
