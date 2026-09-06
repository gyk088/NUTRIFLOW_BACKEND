import IngredientService from '../bll/services/IngredientService.js';

export default class IngredientController {
    static async create(request, reply) {
        try {
            const ingredient = await IngredientService.create(request.body);
            return ingredient;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const ingredient = await IngredientService.getById(id);
            return ingredient;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const { search } = request.query;
            const ingredients = await IngredientService.getAll(search);
            return ingredients;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async update(request, reply) {
        try {
            const { id } = request.params;
            const ingredient = await IngredientService.update(id, request.body);
            return ingredient;
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
}
