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
      deleted_at: {}
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

  static async getByIds(ids) {
    if (!ids.length) return [];
    return IngredientModel.select('WHERE id = ANY($1) AND deleted_at IS NULL', [ids]);
  }

  static async getAll() {
    return IngredientModel.select('WHERE deleted_at IS NULL ORDER BY ctime DESC', []);
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  // Удалённые (deleted_at) сюда не попадают — они идут через getDeletedIdsSince.
  static async getUpdatedSince(since) {
    if (!since) return IngredientModel.getAll();
    return IngredientModel.select('WHERE deleted_at IS NULL AND COALESCE(utime, ctime) > $1 ORDER BY ctime DESC', [since]);
  }

  // id ингредиентов, мягко удалённых после `since` — чтобы /app/sync мог
  // сказать клиенту убрать их из локального кэша. Без `since` (первая
  // синхронизация) отдавать нечего — свежий кэш и так их не содержит.
  static async getDeletedIdsSince(since) {
    if (!since) return [];
    const rows = await IngredientModel.select('WHERE deleted_at IS NOT NULL AND deleted_at > $1', [since]);
    return rows.map(r => r.f.id);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
