import ArticleController from '../../../../controllers/article.js'
import auth from '../../../../hooks/preHendler.js';

// Чтение статей + избранное — для мобильного приложения. Запись — см. routes/v1/admin/articles.
export default async function appArticleRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, ArticleController.getAll);
    fastify.get('/favorites', {preHandler: [auth()]}, ArticleController.getFavorites);
    fastify.get('/:id', {preHandler: [auth()]}, ArticleController.getById);
    fastify.post('/:id/favorite', {preHandler: [auth()]}, ArticleController.addFavorite);
    fastify.delete('/:id/favorite', {preHandler: [auth()]}, ArticleController.removeFavorite);
}
