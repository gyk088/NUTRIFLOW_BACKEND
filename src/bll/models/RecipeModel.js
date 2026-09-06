import { PgObject } from 'pgobject';

export default class RecipeModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      name: {
        required: true
      },
      description: {},
      image_url: {},
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
    return RecipeModel.select('WHERE name ILIKE $1 ORDER BY name LIMIT 50', [`%${name}%`]);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
