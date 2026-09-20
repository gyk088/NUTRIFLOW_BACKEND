import TagController from '../../../../controllers/tag.js'
import auth from '../../../../hooks/preHendler.js';

// Чтение справочника тегов — для мобильного приложения. Запись — см. routes/v1/admin/tags.
export default async function appTagRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, TagController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, TagController.getById);
}
