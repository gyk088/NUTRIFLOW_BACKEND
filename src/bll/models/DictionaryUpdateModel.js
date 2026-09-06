import { PgObject } from 'pgobject';

export default class DictionaryUpdateModel extends PgObject {
  static get schema() {
    return {
      name: {
        pk: true,
        required: true
      },
      utime: {
        default: new Date()
      }
    }
  }

  static get table() {
    return 'dictionary_update';
  }

  static async getAll() {
    return DictionaryUpdateModel.select('ORDER BY name', []);
  }

  // Одним запросом ставит utime = NOW() для справочника — без read-then-write,
  // чтобы параллельные записи в справочник не гонялись друг с другом.
  static async touch(name) {
    return DictionaryUpdateModel.query('UPDATE dictionary_update SET utime = NOW() WHERE name = $1', [name]);
  }
}
