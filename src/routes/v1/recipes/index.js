import RecipeController from '../../../controllers/recipe.js'
import auth from '../../../hooks/preHendler.js';
import { ROLES } from '../../../bll/utils/const.js';

export default async function recipeRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth([ROLES.ADMIN])]}, RecipeController.create);
    fastify.get('/', {preHandler: [auth()]}, RecipeController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, RecipeController.getById);
    fastify.put('/:id', {preHandler: [auth([ROLES.ADMIN])]}, RecipeController.update);
    fastify.delete('/:id', {preHandler: [auth([ROLES.ADMIN])]}, RecipeController.remove);
}
