import UserModel from '../models/UserModel.js';

export default class UserService {
  static async getById(id) {
    const user = await UserModel.getUserById(id);
    if (!user) throw new Error('User not found');
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
