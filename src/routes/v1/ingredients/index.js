import IngredientController from '../../../controllers/ingredient.js'
import auth from '../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../bll/utils/const.js';

export default async function ingredientRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.create);
    fastify.get('/', {preHandler: [auth()]}, IngredientController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, IngredientController.getById);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.update);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, IngredientController.remove);
}
