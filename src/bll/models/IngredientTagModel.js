import PgObject from 'pgobject';

// Связь ингредиента с тегами (junction-таблица ingredient_tag) — управляется
// целиком через IngredientService, отдельных роутов/контроллера для неё нет.
export default class IngredientTagModel extends PgObject {
  static get schema() {
    return {
      ingredient_id: {
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
    return 'ingredient_tag';
  }

  static async getByIngredientId(ingredientId) {
    return IngredientTagModel.select('WHERE ingredient_id = $1', [ingredientId]);
  }

  static async deleteByIngredientId(ingredientId) {
    return IngredientTagModel.query('DELETE FROM ingredient_tag WHERE ingredient_id = $1', [ingredientId]);
  }
}
