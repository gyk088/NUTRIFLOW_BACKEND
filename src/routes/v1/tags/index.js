import TagController from '../../../controllers/tag.js'
import auth from '../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../bll/utils/const.js';

export default async function tagRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, TagController.create);
    fastify.get('/', {preHandler: [auth()]}, TagController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, TagController.getById);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, TagController.update);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, TagController.remove);
}
