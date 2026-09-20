import IngredientController from '../../../../controllers/ingredient.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

// Запись каталога — для админ-панели. Чтение — см. routes/v1/app/ingredients.
export default async function adminIngredientRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.create);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.update);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.remove);
}
