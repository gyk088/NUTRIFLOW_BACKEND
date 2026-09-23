import LanguageService from '../bll/services/LanguageService.js';

export default class LanguageController {
    static async getAll(request, reply) {
        try {
            const languages = await LanguageService.getAll();
            return languages;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async create(request, reply) {
        try {
            const language = await LanguageService.create(request.body);
            return language;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async update(request, reply) {
        try {
            const { code } = request.params;
            const language = await LanguageService.update(code, request.body);
            return language;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async remove(request, reply) {
        try {
            const { code } = request.params;
            const result = await LanguageService.remove(code);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
