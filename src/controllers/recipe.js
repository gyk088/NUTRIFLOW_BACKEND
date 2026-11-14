import RecipeService from '../bll/services/RecipeService.js';
import RecipeExcelService from '../bll/services/RecipeExcelService.js';
import { NotFoundError } from '../bll/utils/ownership.js';

function sendError(reply, error) {
    if (error instanceof NotFoundError) return reply.code(404).send({ error: error.message });
    return reply.code(400).send({ error: error.message });
}

const TRANSLATION_FIELDS = ['name', 'description', 'cook_time', 'steps'];

function splitBody(body) {
  const { languageCode, ingredients, tagIds, ...rest } = body;
  const translationData = {};
  const baseData = {};
  for (const [key, value] of Object.entries(rest)) {
    if (TRANSLATION_FIELDS.includes(key)) translationData[key] = value;
    else baseData[key] = value;
  }
  return { languageCode, translationData, baseData, ingredients, tagIds };
}

export default class RecipeController {
    static async create(request, reply) {
        try {
            const { languageCode, translationData, baseData, ingredients, tagIds } = splitBody(request.body);
            const recipe = await RecipeService.create(languageCode, translationData, baseData, ingredients, tagIds);
            return recipe;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // Резолвит рецепт на один язык (?lang=) — для мобильного приложения.
    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const recipe = await RecipeService.getFullById(id, request.query.lang, { viewerId: request.user.f.id });
            return recipe;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    // Отдаёт все переводы рецепта — для формы редактирования в админке.
    static async getAdminDetail(request, reply) {
        try {
            const { id } = request.params;
            const recipe = await RecipeService.getAdminDetail(id);
            return recipe;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const { search, lang } = request.query;
            const recipes = await RecipeService.getAll(search, lang, request.user.f.id);
            return recipes;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async update(request, reply) {
        try {
            const { id } = request.params;
            const { baseData, ingredients, tagIds } = splitBody(request.body);
            const recipe = await RecipeService.update(id, baseData, ingredients, tagIds);
            return recipe;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async addTranslation(request, reply) {
        try {
            const { id, lang } = request.params;
            const translationData = {};
            for (const key of TRANSLATION_FIELDS) {
                if (request.body[key] !== undefined) translationData[key] = request.body[key];
            }
            const recipe = await RecipeService.addTranslation(id, lang, translationData);
            return recipe;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async removeTranslation(request, reply) {
        try {
            const { id, lang } = request.params;
            const result = await RecipeService.removeTranslation(id, lang);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async remove(request, reply) {
        try {
            const { id } = request.params;
            const result = await RecipeService.remove(id);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // ---- Свои рецепты пользователя приложения (/app/recipes) ----

    static async createOwn(request, reply) {
        try {
            const { languageCode, translationData, baseData, ingredients, tagIds } = splitBody(request.body || {});
            if (!languageCode) throw new Error('languageCode is required');
            return await RecipeService.create(languageCode, translationData, baseData, ingredients, tagIds, { userId: request.user.f.id });
        } catch (error) {
            sendError(reply, error);
        }
    }

    static async getOwn(request, reply) {
        try {
            return await RecipeService.getOwn(request.user.f.id, request.query.lang);
        } catch (error) {
            sendError(reply, error);
        }
    }

    static async updateOwn(request, reply) {
        try {
            return await RecipeService.updateOwn(request.user.f.id, request.params.id, request.body || {});
        } catch (error) {
            sendError(reply, error);
        }
    }

    static async removeOwn(request, reply) {
        try {
            return await RecipeService.removeOwn(request.user.f.id, request.params.id);
        } catch (error) {
            sendError(reply, error);
        }
    }

    // ---- Админка: рецепты пользователей ----

    // ?status=pending (по умолчанию) | published | all, ?search=, ?lang=
    static async getUserCreated(request, reply) {
        try {
            const { status, search, lang } = request.query;
            return await RecipeService.getUserCreated(status || 'pending', search, lang);
        } catch (error) {
            sendError(reply, error);
        }
    }

    static async publish(request, reply) {
        try {
            return await RecipeService.publish(request.params.id);
        } catch (error) {
            sendError(reply, error);
        }
    }

    // Выгрузка всех рецептов (все переводы, состав, теги) в .xlsx.
    static async exportExcel(request, reply) {
        try {
            const buffer = await RecipeExcelService.export();
            reply
                .header('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
                .header('Content-Disposition', 'attachment; filename="recipes.xlsx"')
                .send(buffer);
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    // Загрузка .xlsx обратно: строки с известным id обновляют рецепт,
    // остальные создают новый. Ингредиенты состава ищутся по названию.
    static async importExcel(request, reply) {
        try {
            const file = await request.file();
            const buffer = await file.toBuffer();
            const result = await RecipeExcelService.import(buffer);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
