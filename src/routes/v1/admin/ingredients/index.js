import IngredientController from '../../../../controllers/ingredient.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

// Запись каталога — для админ-панели. Чтение — см. routes/v1/app/ingredients.
export default async function adminIngredientRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.create);
    fastify.get('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.getAdminDetail);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.update);
    fastify.put('/:id/translations/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.addTranslation);
    fastify.delete('/:id/translations/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.removeTranslation);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.remove);
}
