import IngredientController from '../../../../controllers/ingredient.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

// Запись каталога — для админ-панели. Чтение — см. routes/v1/app/ingredients.
export default async function adminIngredientRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.create);
    // Созданные пользователями приложения (?status=pending|published|all).
    fastify.get('/user-created', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.getUserCreated);
    fastify.get('/export', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.exportExcel);
    fastify.post('/import', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.importExcel);
    fastify.get('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.getAdminDetail);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.update);
    fastify.put('/:id/translations/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.addTranslation);
    fastify.delete('/:id/translations/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.removeTranslation);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.remove);
    // Добавить пользовательскую запись в общий каталог.
    fastify.post('/:id/publish', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.publish);
}
