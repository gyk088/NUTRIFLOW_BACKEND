import PgObject from 'pgobject';

export default class ArticleModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      image_url: {},
      ctime: {
        default: new Date()
      },
      utime: {}
    }
  }

  static get table() {
    return 'article';
  }

  static async getById(id) {
    const rows = await ArticleModel.select('WHERE id = $1 LIMIT 1', [id]);
    return rows[0];
  }

  static async getByIds(ids) {
    if (!ids.length) return [];
    return ArticleModel.select('WHERE id = ANY($1)', [ids]);
  }

  static async getAll() {
    return ArticleModel.select('ORDER BY ctime DESC', []);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
