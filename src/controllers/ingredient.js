import IngredientService from '../bll/services/IngredientService.js';
import IngredientExcelService from '../bll/services/IngredientExcelService.js';

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
            const ingredient = await IngredientService.getFullById(id, request.query.lang);
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
            const ingredients = await IngredientService.getAll(search, lang);
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
