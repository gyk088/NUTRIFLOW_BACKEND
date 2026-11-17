import UserEntryController from '../../../../controllers/userEntry.js'
import auth from '../../../../hooks/preHendler.js';

// Личные данные из приложения — дневник питания, вода, избранные рецепты
// (таблица user_entry, install/steps/24.sql). Только свои, только с токеном.
//   GET  /?since=<ISO>  — изменения после since (без since — все записи)
//   POST /batch         — { upserts: [...], deletes: [...] }, до 500 элементов
export default async function appUserDataRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, UserEntryController.getChanges);
    fastify.post('/batch', {preHandler: [auth()]}, UserEntryController.applyBatch);
}
