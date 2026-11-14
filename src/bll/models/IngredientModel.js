import PgObject from 'pgobject';
import { NUTRIENT_FIELDS } from '../utils/nutrients.js';

export default class IngredientModel extends PgObject {
  static get schema() {
    const schema = {
      id: {
        pk: true
      },
      image_url: {},
      grams_per_unit: {},
      default_unit: {
        default: 'g'
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
    };

    // все нутриенты — NOT NULL DEFAULT 0 в БД, поэтому default в схему не
    // добавляем: pgobject трактует default: 0 как falsy и не применяет его
    // (см. __setStaticFields), а незаполненное поле просто не попадёт в
    // INSERT и получит значение по умолчанию из самой БД.
    for (const field of NUTRIENT_FIELDS) {
      schema[field] = {};
    }

    return schema;
  }

  static get table() {
    return 'ingredient';
  }

  static async getById(id) {
    const rows = await IngredientModel.select('WHERE id = $1 AND deleted_at IS NULL LIMIT 1', [id]);
    return rows[0];
  }

  // Без фильтра видимости — для состава рецепта и внутренних проверок.
  static async getByIds(ids) {
    if (!ids.length) return [];
    return IngredientModel.select('WHERE id = ANY($1) AND deleted_at IS NULL', [ids]);
  }

  // Общий каталог (без личных ингредиентов пользователей) — админка, Excel.
  static async getAll() {
    return IngredientModel.select('WHERE deleted_at IS NULL AND is_public ORDER BY ctime DESC', []);
  }

  // Каталог + личные ингредиенты пользователя `userId` (без userId — только каталог).
  static async getVisible(userId, ids = null) {
    const values = [userId || null];
    let where = 'WHERE deleted_at IS NULL AND (is_public OR user_id = $1)';
    if (ids) {
      if (!ids.length) return [];
      values.push(ids);
      where += ' AND id = ANY($2)';
    }
    return IngredientModel.select(`${where} ORDER BY ctime DESC`, values);
  }

  // Все (не удалённые) ингредиенты, созданные пользователем, — и личные, и
  // уже добавленные в каталог.
  static async getByUserId(userId) {
    return IngredientModel.select('WHERE deleted_at IS NULL AND user_id = $1 ORDER BY ctime DESC', [userId]);
  }

  // Для админки: ингредиенты, созданные пользователями. status: pending
  // (ещё личные) | published (добавлены в каталог) | all.
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
    return IngredientModel.select(`${where} ORDER BY ctime DESC`, values);
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  // Удалённые (deleted_at) сюда не попадают — они идут через getDeletedIdsSince.
  // userId — добавить личные ингредиенты этого пользователя.
  static async getUpdatedSince(since, userId = null) {
    if (!since) return IngredientModel.getVisible(userId);
    return IngredientModel.select(
      'WHERE deleted_at IS NULL AND (is_public OR user_id = $2) AND COALESCE(utime, ctime) > $1 ORDER BY ctime DESC',
      [since, userId]
    );
  }

  // id ингредиентов, мягко удалённых после `since` — чтобы /app/sync мог
  // сказать клиенту убрать их из локального кэша. Без `since` (первая
  // синхронизация) отдавать нечего — свежий кэш и так их не содержит.
  static async getDeletedIdsSince(since, userId = null) {
    if (!since) return [];
    const rows = await IngredientModel.select(
      'WHERE deleted_at IS NOT NULL AND deleted_at > $1 AND (is_public OR user_id = $2)',
      [since, userId]
    );
    return rows.map(r => r.f.id);
  }

  // Безвозвратное удаление всех личных ингредиентов пользователя (удаление
  // аккаунта). Связи со своими рецептами чистятся здесь же.
  static async hardDeletePrivateByUserId(userId) {
    const rows = await IngredientModel.select('WHERE user_id = $1 AND NOT is_public', [userId]);
    const ids = rows.map(r => r.f.id);
    if (ids.length) {
      await IngredientModel.query('DELETE FROM recipe_ingredient WHERE ingredient_id = ANY($1)', [ids]);
      await IngredientModel.query('DELETE FROM ingredient_tag WHERE ingredient_id = ANY($1)', [ids]);
      await IngredientModel.query('DELETE FROM ingredient_translation WHERE ingredient_id = ANY($1)', [ids]);
      await IngredientModel.query('DELETE FROM ingredient WHERE id = ANY($1)', [ids]);
    }
    return rows;
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
