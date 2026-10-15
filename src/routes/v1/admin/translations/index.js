import AppTranslationController from '../../../../controllers/appTranslation.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

// Запись словаря текстов интерфейса — для админ-панели. Чтение (резолвленное,
// с fallback) — см. routes/v1/app/translations.
export default async function adminTranslationRoutes(fastify, _options) {
    fastify.get('/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, AppTranslationController.getAdminDictionary);
    fastify.put('/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, AppTranslationController.setDictionary);
    fastify.delete('/:lang/:key', {preHandler: [auth(ADMIN_AND_ABOVE)]}, AppTranslationController.removeKey);
}
