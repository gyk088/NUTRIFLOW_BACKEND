import PgObject from 'pgobject';

export default class TagTranslationModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      tag_id: {
        required: true
      },
      language_code: {
        required: true
      },
      name: {
        required: true
      }
    }
  }

  static get table() {
    return 'tag_translation';
  }

  static async getByTagId(tagId) {
    return TagTranslationModel.select('WHERE tag_id = $1', [tagId]);
  }

  static async getByTagIds(tagIds) {
    if (!tagIds.length) return [];
    return TagTranslationModel.select('WHERE tag_id = ANY($1)', [tagIds]);
  }

  static async getByTagIdAndLanguage(tagId, languageCode) {
    const rows = await TagTranslationModel.select('WHERE tag_id = $1 AND language_code = $2 LIMIT 1', [tagId, languageCode]);
    return rows[0];
  }

  // Для проверки дублей при создании тега (тот же тип + язык + название).
  // JOIN за пределами своей таблицы — select() всегда делает `SELECT * FROM
  // <table>`, поэтому здесь нужен query() с явным классом для гидратации.
  static async getByTypeLanguageAndName(type, languageCode, name) {
    const rows = await TagTranslationModel.query(
      `SELECT tt.* FROM tag_translation tt JOIN tag t ON t.id = tt.tag_id
       WHERE t.type = $1 AND tt.language_code = $2 AND tt.name = $3 LIMIT 1`,
      [type, languageCode, name],
      TagTranslationModel
    );
    return rows[0];
  }

  static async deleteByTagId(tagId) {
    return TagTranslationModel.query('DELETE FROM tag_translation WHERE tag_id = $1', [tagId]);
  }
}
