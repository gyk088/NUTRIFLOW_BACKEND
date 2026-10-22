import TagController from '../../../../controllers/tag.js'
import { optionalAuth } from '../../../../hooks/preHendler.js';

// Чтение справочника тегов — для мобильного приложения. Запись — см. routes/v1/admin/tags.
// Публично (optionalAuth): нужны и гостю для /app/sync (categorySlugs и т.п.),
// сами теги не содержат ничего приватного.
export default async function appTagRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [optionalAuth()]}, TagController.getAll);
    fastify.get('/:id', {preHandler: [optionalAuth()]}, TagController.getById);
}
