import IngredientService from '../bll/services/IngredientService.js';
import IngredientExcelService from '../bll/services/IngredientExcelService.js';
import { NotFoundError } from '../bll/utils/ownership.js';

function sendError(reply, error) {
    if (error instanceof NotFoundError) return reply.code(404).send({ error: error.message });
    if (error.code === 'INGREDIENT_IN_USE') return reply.code(409).send({ error: error.message, code: error.code, recipeIds: error.recipeIds });
    return reply.code(400).send({ error: error.message });
}

export default class IngredientController {
    static async create(request, reply) {
        try {
            const { languageCode, name, description, tagIds, ...data } = request.body;
            const ingredient = await IngredientService.create(languageCode, name, data, tagIds, description);
            return ingredient;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // Резолвит ингредиент на один язык (?lang=) — для мобильного приложения.
    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const ingredient = await IngredientService.getFullById(id, request.query.lang, { viewerId: request.user.f.id });
            return ingredient;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    // Отдаёт все переводы ингредиента — для формы редактирования в админке.
    static async getAdminDetail(request, reply) {
        try {
            const { id } = request.params;
            const ingredient = await IngredientService.getAdminDetail(id);
            return ingredient;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const { search, lang } = request.query;
            const ingredients = await IngredientService.getAll(search, lang, request.user.f.id);
            return ingredients;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async update(request, reply) {
        try {
            const { id } = request.params;
            const { tagIds, ...data } = request.body;
            const ingredient = await IngredientService.update(id, data, tagIds);
            return ingredient;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async addTranslation(request, reply) {
        try {
            const { id, lang } = request.params;
            const ingredient = await IngredientService.addTranslation(id, lang, request.body.name, request.body.description);
            return ingredient;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async removeTranslation(request, reply) {
        try {
            const { id, lang } = request.params;
            const result = await IngredientService.removeTranslation(id, lang);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async remove(request, reply) {
        try {
            const { id } = request.params;
            const result = await IngredientService.remove(id);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // ---- Свои ингредиенты пользователя приложения (/app/ingredients) ----

    static async createOwn(request, reply) {
        try {
            const { languageCode, name, description, tagIds, ...data } = request.body || {};
            if (!languageCode) throw new Error('languageCode is required');
            const ingredient = await IngredientService.create(languageCode, name, data, tagIds, description, { userId: request.user.f.id });
            return ingredient;
        } catch (error) {
            sendError(reply, error);
        }
    }

    static async getOwn(request, reply) {
        try {
            return await IngredientService.getOwn(request.user.f.id, request.query.lang);
        } catch (error) {
            sendError(reply, error);
        }
    }

    static async updateOwn(request, reply) {
        try {
            return await IngredientService.updateOwn(request.user.f.id, request.params.id, request.body || {});
        } catch (error) {
            sendError(reply, error);
        }
    }

    static async removeOwn(request, reply) {
        try {
            return await IngredientService.removeOwn(request.user.f.id, request.params.id);
        } catch (error) {
            sendError(reply, error);
        }
    }

    // ---- Админка: ингредиенты пользователей ----

    // ?status=pending (по умолчанию) | published | all, ?search=, ?lang=
    static async getUserCreated(request, reply) {
        try {
            const { status, search, lang } = request.query;
            return await IngredientService.getUserCreated(status || 'pending', search, lang);
        } catch (error) {
            sendError(reply, error);
        }
    }

    static async publish(request, reply) {
        try {
            return await IngredientService.publish(request.params.id);
        } catch (error) {
            sendError(reply, error);
        }
    }

    // Выгрузка всех ингредиентов (все переводы, нутриенты, теги) в .xlsx.
    static async exportExcel(request, reply) {
        try {
            const buffer = await IngredientExcelService.export();
            reply
                .header('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                .header('Content-Disposition', 'attachment; filename="ingredients.xlsx"')
                .send(buffer);
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // Загрузка .xlsx обратно: строки с известным id обновляют ингредиент,
    // остальные создают новый.
    static async importExcel(request, reply) {
        try {
            const file = await request.file();
            const buffer = await file.toBuffer();
            const result = await IngredientExcelService.import(buffer);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
