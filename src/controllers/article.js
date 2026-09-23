import ArticleService from '../bll/services/ArticleService.js';

export default class ArticleController {
    static async create(request, reply) {
        try {
            const { languageCode, title, content, tagIds, ...baseData } = request.body;
            const article = await ArticleService.create(languageCode, { title, content }, baseData, tagIds);
            return article;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // Резолвит статью на один язык (?lang=) — для мобильного приложения.
    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const article = await ArticleService.getFullById(id, request.query.lang, request.user.f.id);
            return article;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    // Отдаёт все переводы статьи — для формы редактирования в админке.
    static async getAdminDetail(request, reply) {
        try {
            const { id } = request.params;
            const article = await ArticleService.getAdminDetail(id);
            return article;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const { search, lang } = request.query;
            const articles = await ArticleService.getAll(lang, search, request.user.f.id);
            return articles;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async update(request, reply) {
        try {
            const { id } = request.params;
            const { tagIds, ...baseData } = request.body;
            const article = await ArticleService.update(id, baseData, tagIds);
            return article;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async addTranslation(request, reply) {
        try {
            const { id, lang } = request.params;
            const article = await ArticleService.addTranslation(id, lang, request.body);
            return article;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async removeTranslation(request, reply) {
        try {
            const { id, lang } = request.params;
            const result = await ArticleService.removeTranslation(id, lang);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async remove(request, reply) {
        try {
            const { id } = request.params;
            const result = await ArticleService.remove(id);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async getFavorites(request, reply) {
        try {
            const articles = await ArticleService.getFavorites(request.user.f.id, request.query.lang);
            return articles;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async addFavorite(request, reply) {
        try {
            const { id } = request.params;
            const result = await ArticleService.addFavorite(request.user.f.id, id);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async removeFavorite(request, reply) {
        try {
            const { id } = request.params;
            const result = await ArticleService.removeFavorite(request.user.f.id, id);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
