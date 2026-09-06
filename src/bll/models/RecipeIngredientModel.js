import { PgObject } from 'pgobject';

// Состав рецепта (junction-таблица recipe_ingredient) — управляется целиком
// через RecipeService, отдельных роутов/контроллера для неё нет.
export default class RecipeIngredientModel extends PgObject {
  static get schema() {
    return {
      recipe_id: {
        pk: true,
        required: true
      },
      ingredient_id: {
        pk: true,
        required: true
      },
      quantity: {
        required: true
      },
      unit: {
        default: 'g'
      }
    }
  }

  static get table() {
    return 'recipe_ingredient';
  }

  static async getByRecipeId(recipeId) {
    return RecipeIngredientModel.select('WHERE recipe_id = $1', [recipeId]);
  }

  static async deleteByRecipeId(recipeId) {
    return RecipeIngredientModel.query('DELETE FROM recipe_ingredient WHERE recipe_id = $1', [recipeId]);
  }
}
