// ШАБЛОН для новой сущности. Скопируйте в <entity>.js.
// Контроллер: try/catch, коды ответа, ноль бизнес-логики.
import ExampleService from '../bll/services/_ExampleService.js';

export default class ExampleController {
    static async create(request, reply) {
        try {
            const item = await ExampleService.create(request.body, request.user.f.id);
            return item;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const item = await ExampleService.getById(id, request.user.f.id);
            return item;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const items = await ExampleService.getAllForUser(request.user.f.id);
            return items;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async update(request, reply) {
        try {
            const { id } = request.params;
            const item = await ExampleService.update(id, request.body, request.user.f.id);
            return item;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async remove(request, reply) {
        try {
            const { id } = request.params;
            const result = await ExampleService.remove(id, request.user.f.id);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
