import PgObject from 'pgobject';

export default class AppTranslationModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      language_code: {
        required: true
      },
      key: {
        required: true
      },
      value: {
        required: true
      },
      ctime: {
        default: new Date()
      },
      utime: {}
    }
  }

  static get table() {
    return 'app_translation';
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }

  static async getByLanguage(languageCode) {
    return AppTranslationModel.select('WHERE language_code = $1', [languageCode]);
  }

  static async getByLanguageAndKey(languageCode, key) {
    const rows = await AppTranslationModel.select('WHERE language_code = $1 AND key = $2 LIMIT 1', [languageCode, key]);
    return rows[0];
  }
}
