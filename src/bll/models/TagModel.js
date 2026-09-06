import { PgObject } from 'pgobject';

export default class TagModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      type: {
        required: true
      },
      name: {
        required: true
      }
    }
  }

  static get table() {
    return 'tag';
  }

  static async getById(id) {
    const rows = await TagModel.select('WHERE id = $1 LIMIT 1', [id]);
    return rows[0];
  }

  static async getByIds(ids) {
    if (!ids.length) return [];
    return TagModel.select('WHERE id = ANY($1)', [ids]);
  }

  static async getByTypeAndName(type, name) {
    const rows = await TagModel.select('WHERE type = $1 AND name = $2 LIMIT 1', [type, name]);
    return rows[0];
  }

  static async getAll(type) {
    if (type) return TagModel.select('WHERE type = $1 ORDER BY name', [type]);
    return TagModel.select('ORDER BY type, name', []);
  }
}
