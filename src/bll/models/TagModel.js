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
      utime: {},
      deleted_at: {}
    }
  }

  static get table() {
    return 'tag';
  }

  static async getById(id) {
    const rows = await TagModel.select('WHERE id = $1 AND deleted_at IS NULL LIMIT 1', [id]);
    return rows[0];
  }

  static async getByIds(ids) {
    if (!ids.length) return [];
    return TagModel.select('WHERE id = ANY($1) AND deleted_at IS NULL', [ids]);
  }

  static async getAll(type) {
    if (type) return TagModel.select('WHERE type = $1 AND deleted_at IS NULL ORDER BY ctime', [type]);
    return TagModel.select('WHERE deleted_at IS NULL ORDER BY type, ctime', []);
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  // Удалённые (deleted_at) сюда не попадают — они идут через getDeletedIdsSince.
  static async getUpdatedSince(since) {
    if (!since) return TagModel.getAll();
    return TagModel.select('WHERE deleted_at IS NULL AND COALESCE(utime, ctime) > $1 ORDER BY type, ctime', [since]);
  }

  // id тегов, мягко удалённых после `since` — чтобы /app/sync мог сказать
  // клиенту убрать их из локального кэша. Без `since` отдавать нечего.
  static async getDeletedIdsSince(since) {
    if (!since) return [];
    const rows = await TagModel.select('WHERE deleted_at IS NOT NULL AND deleted_at > $1', [since]);
    return rows.map(r => r.f.id);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
