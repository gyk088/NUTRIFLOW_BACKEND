import PgObject from 'pgobject';

// Связь статьи с тегами (junction-таблица article_tag) — управляется целиком
// через ArticleService, отдельных роутов/контроллера для неё нет.
export default class ArticleTagModel extends PgObject {
  static get schema() {
    return {
      article_id: {
        pk: true,
        required: true
      },
      tag_id: {
        pk: true,
        required: true
      }
    }
  }

  static get table() {
    return 'article_tag';
  }

  static async getByArticleId(articleId) {
    return ArticleTagModel.select('WHERE article_id = $1', [articleId]);
  }

  static async deleteByArticleId(articleId) {
    return ArticleTagModel.query('DELETE FROM article_tag WHERE article_id = $1', [articleId]);
  }
}
