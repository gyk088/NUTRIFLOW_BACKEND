// ШАБЛОН для новой сущности. Скопируйте в <Entity>Service.js.
// Здесь живёт бизнес-логика и проверки прав — контроллер только парсит
// request/reply, модель только читает/пишет строки.
import ExampleModel from '../models/_ExampleModel.js';

export default class ExampleService {
  static async create(data, userId) {
    const item = new ExampleModel({ ...data, user_id: userId });
    await item.save();
    return item;
  }

  static async getById(id, userId) {
    const item = await ExampleModel.getById(id);
    if (!item) throw new Error('Not found');
    if (item.f.user_id !== userId) throw new Error('Forbidden');
    return item;
  }

  static async getAllForUser(userId) {
    return ExampleModel.getByUserId(userId);
  }

  static async update(id, updates, userId) {
    const item = await ExampleService.getById(id, userId);
    Object.assign(item.f, updates);
    await item.save();
    return item;
  }

  static async remove(id, userId) {
    const item = await ExampleService.getById(id, userId);
    await item.delete();
    return { success: true };
  }
}
