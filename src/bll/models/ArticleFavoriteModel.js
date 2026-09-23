import PgObject from 'pgobject';

// Избранные статьи пользователя (junction-таблица article_favorite) —
// управляется целиком через ArticleService, отдельного контроллера нет.
export default class ArticleFavoriteModel extends PgObject {
  static get schema() {
    return {
      user_id: {
        pk: true,
        required: true
      },
      article_id: {
        pk: true,
        required: true
      },
      ctime: {
        default: new Date()
      }
    }
  }

  static get table() {
    return 'article_favorite';
  }

  static async getByUserId(userId) {
    return ArticleFavoriteModel.select('WHERE user_id = $1 ORDER BY ctime DESC', [userId]);
  }

  static async getByUserAndArticle(userId, articleId) {
    const rows = await ArticleFavoriteModel.select('WHERE user_id = $1 AND article_id = $2 LIMIT 1', [userId, articleId]);
    return rows[0];
  }

  static async deleteByArticleId(articleId) {
    return ArticleFavoriteModel.query('DELETE FROM article_favorite WHERE article_id = $1', [articleId]);
  }
}
