import CatalogSyncController from '../../../../controllers/catalogSync.js'
import auth from '../../../../hooks/preHendler.js';

// GET /?since=<ISO-дата> — отдаёт рецепты/ингредиенты/теги, изменённые после
// `since` (или весь каталог, если since не передан — первая синхронизация).
export default async function appSyncRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, CatalogSyncController.sync);
}
