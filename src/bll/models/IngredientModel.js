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
      utime: {}
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
    const rows = await IngredientModel.select('WHERE id = $1 LIMIT 1', [id]);
    return rows[0];
  }

  static async getByIds(ids) {
    if (!ids.length) return [];
    return IngredientModel.select('WHERE id = ANY($1)', [ids]);
  }

  static async getAll() {
    return IngredientModel.select('ORDER BY ctime DESC', []);
  }

  // Для инкрементальной синхронизации каталога (см. CatalogSyncService) — новые
  // строки ещё не имеют utime, поэтому сравниваем с COALESCE(utime, ctime).
  static async getUpdatedSince(since) {
    if (!since) return IngredientModel.getAll();
    return IngredientModel.select('WHERE COALESCE(utime, ctime) > $1 ORDER BY ctime DESC', [since]);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
