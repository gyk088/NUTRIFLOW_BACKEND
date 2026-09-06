// ШАБЛОН для новой сущности. Скопируйте в <Entity>Model.js и отредактируйте:
// 1. переименуйте класс и table
// 2. опишите schema (см. UserModel.js для примеров set()/default)
// 3. добавьте таблицу в install/steps/<N>.sql (см. steps/2.sql.example)
import { PgObject } from 'pgobject';

export default class ExampleModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      user_id: {
        required: true
      },
      name: {
        required: true
      },
      ctime: {
        default: new Date()
      },
      utime: {}
    }
  }

  static get table() {
    return 'my_item';
  }

  static async getById(id) {
    const rows = await ExampleModel.select('WHERE id = $1 LIMIT 1', [id]);
    return rows[0];
  }

  static async getByUserId(userId) {
    return ExampleModel.select('WHERE user_id = $1 ORDER BY ctime DESC', [userId]);
  }

  async update() {
    this.f.utime = new Date();
    return super.update();
  }
}
