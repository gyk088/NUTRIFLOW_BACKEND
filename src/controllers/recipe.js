import RecipeService from '../bll/services/RecipeService.js';

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
            const recipe = await RecipeService.getFullById(id, request.query.lang);
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
            const recipes = await RecipeService.getAll(search, lang);
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
}
