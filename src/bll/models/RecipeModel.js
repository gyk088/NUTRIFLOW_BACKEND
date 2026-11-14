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
      deleted_at: {},
      // владелец — см. install/steps/23.sql
      user_id: {},
      is_public: {},
      published_at: {}
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

  // Общий каталог (без личных рецептов пользователей) — админка, Excel.
  static async getAll() {
    return RecipeModel.select('WHERE deleted_at IS NULL AND is_public ORDER BY ctime DESC', []);
  }

  // Каталог + личные рецепты пользователя `userId` (без userId — только каталог).
  static async getVisible(userId, ids = null) {
    const values = [userId || null];
    let where = 'WHERE deleted_at IS NULL AND (is_public OR user_id = $1)';
    if (ids) {
      if (!ids.length) return [];
      values.push(ids);
      where += ' AND id = ANY($2)';
    }
    return RecipeModel.select(`${where} ORDER BY ctime DESC`, values);
  }

  // Все (не удалённые) рецепты, созданные пользователем, — и личные, и уже
  // добавленные в каталог.
  static async getByUserId(userId) {
    return RecipeModel.select('WHERE deleted_at IS NULL AND user_id = $1 ORDER BY ctime DESC', [userId]);
  }

  // Для админки: рецепты, созданные пользователями. status: pending | published | all.
  static async getUserCreated(status, ids = null) {
    const values = [];
    let where = 'WHERE deleted_at IS NULL AND user_id IS NOT NULL';
    if (status === 'pending') where += ' AND NOT is_public';
    if (status === 'published') where += ' AND is_public';
    if (ids) {
      if (!ids.length) return [];
      values.push(ids);
      where += ' AND id = ANY($1)';
    }
    return RecipeModel.select(`${where} ORDER BY ctime DESC`, values);
  }

  // Не удалённые рецепты, в составе которых есть ингредиент.
  static async getByIngredientId(ingredientId) {
    return RecipeModel.query(
      `SELECT r.* FROM recipe r JOIN recipe_ingredient ri ON ri.recipe_id = r.id
       WHERE ri.ingredient_id = $1 AND r.deleted_at IS NULL`,
      [ingredientId],
      RecipeModel
    );
  }

  // КБЖУ и названия ингредиентов в ответе рецепта считаются на лету из
  // ингредиентов — после их изменения рецепты должны снова уйти в /app/sync.
  static async touchByIngredientId(ingredientId) {
    return RecipeModel.query(
      `UPDATE recipe SET utime = NOW()
       WHERE deleted_at IS NULL AND id IN (SELECT recipe_id FROM recipe_ingredient WHERE ingredient_id = $1)`,
      [ingredientId]
    );
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  // Удалённые (deleted_at) сюда не попадают — они идут через getDeletedIdsSince.
  // userId — добавить личные рецепты этого пользователя.
  static async getUpdatedSince(since, userId = null) {
    if (!since) return RecipeModel.getVisible(userId);
    return RecipeModel.select(
      'WHERE deleted_at IS NULL AND (is_public OR user_id = $2) AND COALESCE(utime, ctime) > $1 ORDER BY ctime DESC',
      [since, userId]
    );
  }

  // id рецептов, мягко удалённых после `since` — чтобы /app/sync мог сказать
  // клиенту убрать их из локального кэша. Без `since` отдавать нечего.
  static async getDeletedIdsSince(since, userId = null) {
    if (!since) return [];
    const rows = await RecipeModel.select(
      'WHERE deleted_at IS NOT NULL AND deleted_at > $1 AND (is_public OR user_id = $2)',
      [since, userId]
    );
    return rows.map(r => r.f.id);
  }

  // Безвозвратное удаление всех личных рецептов пользователя (удаление аккаунта).
  static async hardDeletePrivateByUserId(userId) {
    const rows = await RecipeModel.select('WHERE user_id = $1 AND NOT is_public', [userId]);
    const ids = rows.map(r => r.f.id);
    if (ids.length) {
      await RecipeModel.query('DELETE FROM recipe_ingredient WHERE recipe_id = ANY($1)', [ids]);
      await RecipeModel.query('DELETE FROM recipe_tag WHERE recipe_id = ANY($1)', [ids]);
      await RecipeModel.query('DELETE FROM recipe_translation WHERE recipe_id = ANY($1)', [ids]);
      await RecipeModel.query('DELETE FROM recipe WHERE id = ANY($1)', [ids]);
    }
    return rows;
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
