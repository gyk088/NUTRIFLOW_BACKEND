import RecipeController from '../../../../controllers/recipe.js'
import auth from '../../../../hooks/preHendler.js';

// Чтение каталога — для мобильного приложения. Запись — см. routes/v1/admin/recipes.
export default async function appRecipeRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, RecipeController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, RecipeController.getById);
}
