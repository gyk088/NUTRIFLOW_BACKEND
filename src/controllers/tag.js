import TagService from '../bll/services/TagService.js';

export default class TagController {
    static async create(request, reply) {
        try {
            const { languageCode, type, name } = request.body;
            const tag = await TagService.create(languageCode, type, name);
            return tag;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // Резолвит тег на один язык (?lang=) — для мобильного приложения.
    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const tag = await TagService.getFullById(id, request.query.lang);
            return tag;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    // Отдаёт все переводы тега — для формы редактирования в админке.
    static async getAdminDetail(request, reply) {
        try {
            const { id } = request.params;
            const tag = await TagService.getAdminDetail(id);
            return tag;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const { type, lang } = request.query;
            const tags = await TagService.getAll(type, lang);
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

    static async addTranslation(request, reply) {
        try {
            const { id, lang } = request.params;
            const tag = await TagService.addTranslation(id, lang, request.body.name);
            return tag;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async removeTranslation(request, reply) {
        try {
            const { id, lang } = request.params;
            const result = await TagService.removeTranslation(id, lang);
            return result;
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
