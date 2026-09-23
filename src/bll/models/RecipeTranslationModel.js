import PgObject from 'pgobject';

export default class RecipeTranslationModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      recipe_id: {
        required: true
      },
      language_code: {
        required: true
      },
      name: {
        required: true
      },
      description: {},
      cook_time: {},
      steps: {}
    }
  }

  static get table() {
    return 'recipe_translation';
  }

  static async getByRecipeId(recipeId) {
    return RecipeTranslationModel.select('WHERE recipe_id = $1', [recipeId]);
  }

  static async getByRecipeIdAndLanguage(recipeId, languageCode) {
    const rows = await RecipeTranslationModel.select('WHERE recipe_id = $1 AND language_code = $2 LIMIT 1', [recipeId, languageCode]);
    return rows[0];
  }

  static async searchRecipeIds(query) {
    const rows = await RecipeTranslationModel.select('WHERE name ILIKE $1', [`%${query}%`]);
    return [...new Set(rows.map(r => r.f.recipe_id))];
  }

  static async deleteByRecipeId(recipeId) {
    return RecipeTranslationModel.query('DELETE FROM recipe_translation WHERE recipe_id = $1', [recipeId]);
  }
}
