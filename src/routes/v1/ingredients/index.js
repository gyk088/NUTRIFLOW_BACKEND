import IngredientController from '../../../controllers/ingredient.js'
import auth from '../../../hooks/preHendler.js';
import { ROLES } from '../../../bll/utils/const.js';

export default async function ingredientRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth([ROLES.ADMIN])]}, IngredientController.create);
    fastify.get('/', {preHandler: [auth()]}, IngredientController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, IngredientController.getById);
    fastify.put('/:id', {preHandler: [auth([ROLES.ADMIN])]}, IngredientController.update);
    fastify.delete('/:id', {preHandler: [auth([ROLES.ADMIN])]}, IngredientController.remove);
}
