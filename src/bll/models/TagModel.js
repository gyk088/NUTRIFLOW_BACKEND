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
      name_ru: {
        required: true
      },
      name_en: {
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

  static async getByTypeAndName(type, nameRu) {
    const rows = await TagModel.select('WHERE type = $1 AND name_ru = $2 LIMIT 1', [type, nameRu]);
    return rows[0];
  }

  static async getAll(type) {
    if (type) return TagModel.select('WHERE type = $1 ORDER BY name_ru', [type]);
    return TagModel.select('ORDER BY type, name_ru', []);
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  static async getUpdatedSince(since) {
    if (!since) return TagModel.getAll();
    return TagModel.select('WHERE COALESCE(utime, ctime) > $1 ORDER BY type, name_ru', [since]);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
