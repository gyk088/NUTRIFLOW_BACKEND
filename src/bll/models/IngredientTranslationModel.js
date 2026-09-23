import PgObject from 'pgobject';

export default class IngredientTranslationModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      ingredient_id: {
        required: true
      },
      language_code: {
        required: true
      },
      name: {
        required: true
      }
    }
  }

  static get table() {
    return 'ingredient_translation';
  }

  static async getByIngredientId(ingredientId) {
    return IngredientTranslationModel.select('WHERE ingredient_id = $1', [ingredientId]);
  }

  static async getByIngredientIds(ingredientIds) {
    if (!ingredientIds.length) return [];
    return IngredientTranslationModel.select('WHERE ingredient_id = ANY($1)', [ingredientIds]);
  }

  static async getByIngredientIdAndLanguage(ingredientId, languageCode) {
    const rows = await IngredientTranslationModel.select('WHERE ingredient_id = $1 AND language_code = $2 LIMIT 1', [ingredientId, languageCode]);
    return rows[0];
  }

  static async searchIngredientIds(query) {
    const rows = await IngredientTranslationModel.select('WHERE name ILIKE $1', [`%${query}%`]);
    return [...new Set(rows.map(r => r.f.ingredient_id))];
  }

  static async deleteByIngredientId(ingredientId) {
    return IngredientTranslationModel.query('DELETE FROM ingredient_translation WHERE ingredient_id = $1', [ingredientId]);
  }
}
