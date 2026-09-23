import ArticleController from '../../../../controllers/article.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

// Запись статей — для админ-панели. Чтение/избранное — см. routes/v1/app/articles.
export default async function adminArticleRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, ArticleController.create);
    fastify.get('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, ArticleController.getAdminDetail);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, ArticleController.update);
    fastify.put('/:id/translations/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, ArticleController.addTranslation);
    fastify.delete('/:id/translations/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, ArticleController.removeTranslation);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, ArticleController.remove);
}
