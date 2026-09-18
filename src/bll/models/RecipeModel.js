import PgObject from 'pgobject';

export default class RecipeModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      name_ru: {
        required: true
      },
      name_en: {
        required: true
      },
      description_ru: {},
      description_en: {},
      image_url: {},
      cook_time_ru: {},
      cook_time_en: {},
      steps_ru: {},
      steps_en: {},
      servings: {
        default: 1
      },
      ctime: {
        default: new Date()
      },
      utime: {}
    }
  }

  static get table() {
    return 'recipe';
  }

  static async getById(id) {
    const rows = await RecipeModel.select('WHERE id = $1 LIMIT 1', [id]);
    return rows[0];
  }

  static async getAll() {
    return RecipeModel.select('ORDER BY ctime DESC', []);
  }

  static async search(name) {
    return RecipeModel.select('WHERE name_ru ILIKE $1 OR name_en ILIKE $1 ORDER BY name_ru LIMIT 50', [`%${name}%`]);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
