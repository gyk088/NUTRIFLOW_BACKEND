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
      utime: {},
      deleted_at: {}
    }
  }

  static get table() {
    return 'recipe';
  }

  static async getById(id) {
    const rows = await RecipeModel.select('WHERE id = $1 AND deleted_at IS NULL LIMIT 1', [id]);
    return rows[0];
  }

  static async getByIds(ids) {
    if (!ids.length) return [];
    return RecipeModel.select('WHERE id = ANY($1) AND deleted_at IS NULL', [ids]);
  }

  static async getAll() {
    return RecipeModel.select('WHERE deleted_at IS NULL ORDER BY ctime DESC', []);
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  // Удалённые (deleted_at) сюда не попадают — они идут через getDeletedIdsSince.
  static async getUpdatedSince(since) {
    if (!since) return RecipeModel.getAll();
    return RecipeModel.select('WHERE deleted_at IS NULL AND COALESCE(utime, ctime) > $1 ORDER BY ctime DESC', [since]);
  }

  // id рецептов, мягко удалённых после `since` — чтобы /app/sync мог сказать
  // клиенту убрать их из локального кэша. Без `since` отдавать нечего.
  static async getDeletedIdsSince(since) {
    if (!since) return [];
    const rows = await RecipeModel.select('WHERE deleted_at IS NOT NULL AND deleted_at > $1', [since]);
    return rows.map(r => r.f.id);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
