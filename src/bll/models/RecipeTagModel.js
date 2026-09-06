import PgObject from 'pgobject';

// Связь рецепта с тегами (junction-таблица recipe_tag) — управляется целиком
// через RecipeService, отдельных роутов/контроллера для неё нет.
export default class RecipeTagModel extends PgObject {
  static get schema() {
    return {
      recipe_id: {
        pk: true,
        required: true
      },
      tag_id: {
        pk: true,
        required: true
      }
    }
  }

  static get table() {
    return 'recipe_tag';
  }

  static async getByRecipeId(recipeId) {
    return RecipeTagModel.select('WHERE recipe_id = $1', [recipeId]);
  }

  static async deleteByRecipeId(recipeId) {
    return RecipeTagModel.query('DELETE FROM recipe_tag WHERE recipe_id = $1', [recipeId]);
  }
}
