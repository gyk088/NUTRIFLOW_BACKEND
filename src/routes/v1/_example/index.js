// ШАБЛОН для новой сущности. Скопируйте папку в routes/v1/<entities>/index.js,
// импорт контроллера поправьте на реальное имя, и зарегистрируйте роут в src/index.js.
import ExampleController from '../../../controllers/_example.js'
import auth from '../../../hooks/preHendler.js';

export default async function exampleRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth()]}, ExampleController.create);
    fastify.get('/', {preHandler: [auth()]}, ExampleController.getAll);
    fastify.get('/:id', {preHandler: [auth()]}, ExampleController.getById);
    fastify.put('/:id', {preHandler: [auth()]}, ExampleController.update);
    fastify.delete('/:id', {preHandler: [auth()]}, ExampleController.remove);
}
