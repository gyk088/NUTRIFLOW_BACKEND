import PgObject from 'pgobject';

export default class LanguageModel extends PgObject {
  static get schema() {
    return {
      code: {
        pk: true,
        required: true
      },
      name: {
        required: true
      },
      is_default: {
        default: false
      },
      ctime: {
        default: new Date()
      }
    }
  }

  static get table() {
    return 'language';
  }

  static async getByCode(code) {
    const rows = await LanguageModel.select('WHERE code = $1 LIMIT 1', [code]);
    return rows[0];
  }

  static async getAll() {
    return LanguageModel.select('ORDER BY is_default DESC, name', []);
  }

  static async getDefault() {
    const rows = await LanguageModel.select('WHERE is_default = true LIMIT 1', []);
    return rows[0];
  }

  // Ровно один язык может быть default — снимаем флаг со всех остальных
  // одним запросом перед тем, как проставить его новому языку.
  static async clearDefault() {
    return LanguageModel.query('UPDATE language SET is_default = false WHERE is_default = true', []);
  }
}
