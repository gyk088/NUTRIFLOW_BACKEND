import TagService from '../bll/services/TagService.js';

export default class TagController {
    static async create(request, reply) {
        try {
            const tag = await TagService.create(request.body);
            return tag;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const tag = await TagService.getById(id);
            return tag;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const { type } = request.query;
            const tags = await TagService.getAll(type);
            return tags;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async update(request, reply) {
        try {
            const { id } = request.params;
            const tag = await TagService.update(id, request.body);
            return tag;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async remove(request, reply) {
        try {
            const { id } = request.params;
            const result = await TagService.remove(id);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
