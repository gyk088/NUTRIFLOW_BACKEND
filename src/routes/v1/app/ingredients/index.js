import IngredientController from '../../../../controllers/ingredient.js'
import auth from '../../../../hooks/preHendler.js';

// Чтение каталога — для мобильного приложения. Запись — см. routes/v1/admin/ingredients.
export default async function appIngredientRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, IngredientController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, IngredientController.getById);
}
