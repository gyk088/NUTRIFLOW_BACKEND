import RecipeController from '../../../../controllers/recipe.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

// Запись каталога — для админ-панели. Чтение — см. routes/v1/app/recipes.
export default async function adminRecipeRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.create);
    fastify.get('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.getAdminDetail);
    fastify.put('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.update);
    fastify.put('/:id/translations/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.addTranslation);
    fastify.delete('/:id/translations/:lang', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.removeTranslation);
    fastify.delete('/:id', {preHandler: [auth(ADMIN_AND_ABOVE)]}, RecipeController.remove);
}
