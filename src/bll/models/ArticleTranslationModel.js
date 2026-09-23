import PgObject from 'pgobject';

export default class ArticleTranslationModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      article_id: {
        required: true
      },
      language_code: {
        required: true
      },
      title: {
        required: true
      },
      content: {}
    }
  }

  static get table() {
    return 'article_translation';
  }

  static async getByArticleId(articleId) {
    return ArticleTranslationModel.select('WHERE article_id = $1', [articleId]);
  }

  static async getByArticleIdAndLanguage(articleId, languageCode) {
    const rows = await ArticleTranslationModel.select('WHERE article_id = $1 AND language_code = $2 LIMIT 1', [articleId, languageCode]);
    return rows[0];
  }

  static async searchArticleIds(query) {
    const rows = await ArticleTranslationModel.select('WHERE title ILIKE $1', [`%${query}%`]);
    return [...new Set(rows.map(r => r.f.article_id))];
  }

  static async deleteByArticleId(articleId) {
    return ArticleTranslationModel.query('DELETE FROM article_translation WHERE article_id = $1', [articleId]);
  }
}
