import RecipeController from '../../../../controllers/recipe.js'
import auth from '../../../../hooks/preHendler.js';

// Каталог рецептов для мобильного приложения + свои рецепты пользователя
// (личные, пока админ не добавит их в общий каталог — см.
// install/steps/23.sql). Запись каталога — см. routes/v1/admin/recipes.
export default async function appRecipeRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, RecipeController.getAll);
    fastify.get('/my', {preHandler: [auth()]}, RecipeController.getOwn);
    fastify.get('/:id', {preHandler: [auth()]}, RecipeController.getById);
    fastify.post('/', {preHandler: [auth()]}, RecipeController.createOwn);
    fastify.put('/:id', {preHandler: [auth()]}, RecipeController.updateOwn);
    fastify.delete('/:id', {preHandler: [auth()]}, RecipeController.removeOwn);
}
