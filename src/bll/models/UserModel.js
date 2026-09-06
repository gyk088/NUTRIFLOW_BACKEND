import { PgObject } from 'pgobject'
import bcrypt from 'bcrypt';

export default class UserModel extends PgObject {
  static get schema() {
    return {
      id: {
        pk: true
      },
      name: {},
      surname: {},
      email: {},
      password: {
        set(password) {
          if (password) {
            const saltRounds = 10;
            const hash = bcrypt.hashSync(password, saltRounds);
            return hash;
          }
          return password
        }
      },
      role: {
        default: 'user'
      },
      ctime: {
        default: new Date()
      },
      utime: {},
      active: {
        default: true
      },
      reset_token: {},
      reset_token_expires: {}
    }
  }

  static get table() {
    return 'my_user';
  }

  static async getUserById(id) {
    const users = await UserModel.select("WHERE id = $1 LIMIT 1", [id]);
    return users[0];
  }

  static async getUserByEmail(email) {
    const users = await UserModel.select("WHERE email = $1 LIMIT 1", [email]);
    return users[0];
  }

  static async getUserByResetToken(token) {
    const users = await UserModel.select("WHERE reset_token = $1 LIMIT 1", [token]);
    return users[0];
  }

  toJSON() {
    const objToJson = {};
    const keysToRemove = ['password', 'reset_token', 'reset_token_expires'];
    for (const key in this.f) {
      if (keysToRemove.includes(key)) continue;
      objToJson[key] = this.f[key];
    }
    return objToJson;
  }
}
