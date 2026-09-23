import PgObject from 'pgobject';

export default class TagModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      type: {
        required: true
      },
      ctime: {
        default: new Date()
      },
      utime: {}
    }
  }

  static get table() {
    return 'tag';
  }

  static async getById(id) {
    const rows = await TagModel.select('WHERE id = $1 LIMIT 1', [id]);
    return rows[0];
  }

  static async getByIds(ids) {
    if (!ids.length) return [];
    return TagModel.select('WHERE id = ANY($1)', [ids]);
  }

  static async getAll(type) {
    if (type) return TagModel.select('WHERE type = $1 ORDER BY ctime', [type]);
    return TagModel.select('ORDER BY type, ctime', []);
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  static async getUpdatedSince(since) {
    if (!since) return TagModel.getAll();
    return TagModel.select('WHERE COALESCE(utime, ctime) > $1 ORDER BY type, ctime', [since]);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
