import LanguageController from '../../../../controllers/language.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

// Запись списка языков — для админ-панели. Чтение — см. routes/v1/app/languages.
export default async function adminLanguageRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, LanguageController.create);
    fastify.put('/:code', {preHandler: [auth(ADMIN_AND_ABOVE)]}, LanguageController.update);
    fastify.delete('/:code', {preHandler: [auth(ADMIN_AND_ABOVE)]}, LanguageController.remove);
}
