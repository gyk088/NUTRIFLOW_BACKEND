import IngredientController from '../../../../controllers/ingredient.js'
import auth from '../../../../hooks/preHendler.js';

// Каталог ингредиентов для мобильного приложения + свои ингредиенты
// пользователя (личные, пока админ не добавит их в общий каталог — см.
// install/steps/23.sql). Запись каталога — см. routes/v1/admin/ingredients.
export default async function appIngredientRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, IngredientController.getAll);
    fastify.get('/my', {preHandler: [auth()]}, IngredientController.getOwn);
    fastify.get('/:id', {preHandler: [auth()]}, IngredientController.getById);
    fastify.post('/', {preHandler: [auth()]}, IngredientController.createOwn);
    fastify.put('/:id', {preHandler: [auth()]}, IngredientController.updateOwn);
    fastify.delete('/:id', {preHandler: [auth()]}, IngredientController.removeOwn);
}
