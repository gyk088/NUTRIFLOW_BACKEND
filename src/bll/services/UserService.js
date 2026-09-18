import UserModel from '../models/UserModel.js';
import { ROLES } from '../utils/const.js';

const ASSIGNABLE_ROLES = [ROLES.SUPER_ADMIN, ROLES.ADMIN, ROLES.USER];

export default class UserService {
  static async getById(id) {
    const user = await UserModel.getUserById(id);
    if (!user) throw new Error('User not found');
    return user;
  }

  static async getAll() {
    return UserModel.getAll();
  }

  // Доступ ограничен на уровне роута (auth([ROLES.SUPER_ADMIN]) в
  // routes/v1/users) — сюда попадают только запросы от super_admin. Менять
  // свою собственную роль нельзя — иначе можно случайно разжаловать себя
  // без другого super_admin, способного вернуть доступ.
  static async setRole(actingUserId, targetUserId, role) {
    if (!ASSIGNABLE_ROLES.includes(role)) throw new Error('invalid role');
    if (actingUserId === targetUserId) throw new Error('cannot change your own role');

    const user = await UserService.getById(targetUserId);
    user.f.role = role;
    user.f.utime = new Date();
    await user.save();

    return user;
  }

  static async updateProfile(userId, updates) {
    const user = await UserModel.getUserById(userId);
    if (!user) throw new Error('User not found');

    const allowed = [
      'name', 'surname',
      // профиль/анкета — см. install/steps/1.sql
      'sex', 'age', 'height_cm', 'weight_kg', 'target_weight_kg',
      'activity_level', 'goal_type', 'manual_calorie_target', 'manual_macro_split',
      'preferences'
    ];
    for (const key of allowed) {
      if (updates[key] !== undefined) user.f[key] = updates[key];
    }
    user.f.utime = new Date();
    await user.save();

    return user;
  }
}
