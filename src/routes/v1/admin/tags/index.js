import TagController from '../../../../controllers/tag.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

// Запись справочника тегов — для админ-панели. Чтение — см. routes/v1/app/tags.
export default async function adminTagRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, TagController.create);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, TagController.update);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, TagController.remove);
}
