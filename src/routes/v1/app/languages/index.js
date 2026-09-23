import LanguageController from '../../../../controllers/language.js'

// Чтение списка языков — публично и без авторизации: экран выбора языка в
// мобильном приложении показывается ДО логина/регистрации. Тоже читается
// админкой как источник опций. Запись — см. routes/v1/admin/languages.
export default async function appLanguageRoutes(fastify, _options) {
    fastify.get('/', LanguageController.getAll);
}
