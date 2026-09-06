import RecipeService from '../bll/services/RecipeService.js';

export default class RecipeController {
    static async create(request, reply) {
        try {
            const { ingredients, tagIds, ...data } = request.body;
            const recipe = await RecipeService.create(data, ingredients, tagIds);
            return recipe;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const recipe = await RecipeService.getFullById(id);
            return recipe;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const { search } = request.query;
            const recipes = await RecipeService.getAll(search);
            return recipes;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async update(request, reply) {
        try {
            const { id } = request.params;
            const { ingredients, tagIds, ...data } = request.body;
            const recipe = await RecipeService.update(id, data, ingredients, tagIds);
            return recipe;
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
