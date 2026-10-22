import CatalogSyncController from '../../../../controllers/catalogSync.js'
import { optionalAuth } from '../../../../hooks/preHendler.js';

// GET /?since=<ISO-дата> — отдаёт рецепты/ингредиенты/теги, изменённые после
// `since` (или весь каталог, если since не передан — первая синхронизация).
// Без токена (гость) — тот же каталог, но рецепты без КБЖУ и без каталога
// ингредиентов (см. CatalogSyncService.sync).
export default async function appSyncRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [optionalAuth()]}, CatalogSyncController.sync);
}
