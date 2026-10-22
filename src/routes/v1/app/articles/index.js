import ArticleController from '../../../../controllers/article.js'
import auth, { optionalAuth } from '../../../../hooks/preHendler.js';

// Чтение статей — публично (optionalAuth): нужно и гостю (см. /app/sync-style
// гостевой доступ в CatalogSyncService), isFavorite просто всегда false без
// пользователя. Избранное — только авторизованным.
export default async function appArticleRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [optionalAuth()]}, ArticleController.getAll);
    fastify.get('/favorites', {preHandler: [auth()]}, ArticleController.getFavorites);
    fastify.get('/:id', {preHandler: [optionalAuth()]}, ArticleController.getById);
    fastify.post('/:id/favorite', {preHandler: [auth()]}, ArticleController.addFavorite);
    fastify.delete('/:id/favorite', {preHandler: [auth()]}, ArticleController.removeFavorite);
}
