import RecipeController from '../../../controllers/recipe.js'
import auth from '../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../bll/utils/const.js';

export default async function recipeRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.create);
    fastify.get('/', {preHandler: [auth()]}, RecipeController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, RecipeController.getById);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.update);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.remove);
}
