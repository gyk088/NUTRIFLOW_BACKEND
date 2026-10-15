import AppTranslationController from '../../../../controllers/appTranslation.js'

// Чтение словаря текстов интерфейса — публично и без авторизации, те же
// соображения, что у /app/languages: нужен до логина/регистрации. Запись —
// см. routes/v1/admin/translations.
export default async function appTranslationRoutes(fastify, _options) {
    fastify.get('/', AppTranslationController.getDictionary);
}
