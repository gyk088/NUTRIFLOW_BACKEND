import PgObject from 'pgobject';

export default class RecipeModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
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

  static async getByIds(ids) {
    if (!ids.length) return [];
    return RecipeModel.select('WHERE id = ANY($1)', [ids]);
  }

  static async getAll() {
    return RecipeModel.select('ORDER BY ctime DESC', []);
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  static async getUpdatedSince(since) {
    if (!since) return RecipeModel.getAll();
    return RecipeModel.select('WHERE COALESCE(utime, ctime) > $1 ORDER BY ctime DESC', [since]);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
