import UserModel from '../models/UserModel.js'
import SessionModel from '../models/SessionModel.js';
import { validateEmail } from '../utils/helpers.js'
import Mailer from '../utils/Mailer.js'
import bcrypt from 'bcrypt';
import crypto from 'crypto';

export default class AuthService {
  static async loginByPassword(email, password, ip, user_agent) {
    email = email?.toLowerCase();
    let user = await UserModel.getUserByEmail(email);

    if (!user) throw new Error('email is invalid');
    if (user.f.active === false) throw new Error('user is blocked');

    if (!user.f.password) throw new Error('password is null');
    if (!bcrypt.compareSync(password, user.f.password)) throw new Error('password is invalid');

    const session = new SessionModel({
      user_id: user.f.id,
      ip,
      user_agent
    });
    await session.generateToken();
    await session.save();

    return { session, user }
  }

  static async register(userData, ip, user_agent) {
    const email = userData.email?.toLowerCase();

    if (!email || !validateEmail(email)) throw new Error('email is invalid');
    if (!userData.password || userData.password.length < 6) throw new Error('password must be at least 6 characters');

    const existingUser = await UserModel.getUserByEmail(email);
    if (existingUser) throw new Error('email is already registered');

    // Роль жёстко фиксирована и не читается из userData — иначе клиент мог бы
    // прислать role: "admin" и получить повышенные права.
    const user = new UserModel({
      name: userData.name,
      surname: userData.surname,
      email,
      password: userData.password
    });
    await user.save();

    const session = new SessionModel({
      user_id: user.f.id,
      ip,
      user_agent
    });
    await session.generateToken();
    await session.save();

    return { session, user }
  }

  static async requestPasswordReset(email) {
    email = email?.toLowerCase();
    if (!email || !validateEmail(email)) throw new Error('email is invalid');

    const user = await UserModel.getUserByEmail(email);

    // Ответ одинаковый независимо от того, существует ли email — чтобы не
    // раскрывать базу пользователей.
    if (user) {
      const token = crypto.randomBytes(32).toString('hex');
      const expires = new Date(Date.now() + 60 * 60 * 1000); // 1 час

      user.f.reset_token = token;
      user.f.reset_token_expires = expires;
      await user.save();

      const resetLink = `${process.env.FRONTEND_URL}/auth?token=${token}`;
      await Mailer.sendPasswordReset(email, resetLink);
    }

    return { success: true, message: 'Если такой email зарегистрирован, на него отправлена ссылка для восстановления' };
  }

  static async resetPassword(token, password) {
    if (!token) throw new Error('token is required');
    if (!password || password.length < 6) throw new Error('password must be at least 6 characters');

    const user = await UserModel.getUserByResetToken(token);
    if (!user) throw new Error('invalid or expired token');

    if (!user.f.reset_token_expires || new Date(user.f.reset_token_expires) < new Date()) {
      throw new Error('invalid or expired token');
    }

    user.f.password = password;
    user.f.reset_token = null;
    user.f.reset_token_expires = null;
    await user.save();

    return { success: true, message: 'Password updated successfully' };
  }

  static async changePassword(userId, currentPassword, newPassword) {
    if (!newPassword || newPassword.length < 6) throw new Error('password must be at least 6 characters');

    const user = await UserModel.getUserById(userId);
    if (!user) throw new Error('User not found');

    if (!user.f.password) throw new Error('password is null');
    if (!bcrypt.compareSync(currentPassword || '', user.f.password)) throw new Error('password is invalid');

    user.f.password = newPassword;
    await user.save();

    return { success: true, message: 'Password updated successfully' };
  }

  static async getSessions(userId) {
    return SessionModel.getSessionsByUserId(userId);
  }

  static async revokeSession(userId, token) {
    if (!token) throw new Error('token is required');

    const session = await SessionModel.getSessionByUserIdAndToken(userId, token);
    if (!session) throw new Error('Session not found');

    await session.delete();
    return { success: true, message: 'Session revoked' };
  }

  static async revokeOtherSessions(userId, currentToken) {
    const sessions = await SessionModel.getSessionsByUserId(userId);
    let revoked = 0;

    for (const session of sessions) {
      if (session.f.token !== currentToken) {
        await session.delete();
        revoked++;
      }
    }

    return { success: true, revoked };
  }

  /**
   * Заблокированный пользователь (active === false) считается неавторизованным —
   * все его существующие токены сразу перестают работать без отдельного отзыва.
  */
  static async loginByToken(token, ip, user_agent, fcm_token) {
    const session = await SessionModel.getSessionByToken(token);
    if (!session) return null;
    session.f.ip = ip;
    session.f.fcm_token = fcm_token;
    session.f.user_agent = user_agent;
    session.f.utime = new Date();
    await session.save();

    const user = await UserModel.getUserById(session.f.user_id);
    if (!user || user.f.active === false) return null;

    return { user, impersonatedBy: session.f.impersonated_by || null };
  }
}
