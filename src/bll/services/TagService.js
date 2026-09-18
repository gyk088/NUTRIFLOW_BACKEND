import TagModel from '../models/TagModel.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
import { DICTIONARIES } from '../utils/const.js';

export default class TagService {
  static async create(data) {
    const existing = await TagModel.getByTypeAndName(data.type, data.name_ru);
    if (existing) throw new Error('Tag with this type/name already exists');

    const tag = new TagModel(data);
    await tag.save();
    await DictionaryUpdateModel.touch(DICTIONARIES.TAG);
    return tag;
  }

  static async getById(id) {
    const tag = await TagModel.getById(id);
    if (!tag) throw new Error('Tag not found');
    return tag;
  }

  static async getAll(type) {
    return TagModel.getAll(type);
  }

  static async update(id, updates) {
    const tag = await TagService.getById(id);

    const allowed = ['type', 'name_ru', 'name_en'];
    for (const key of allowed) {
      if (updates[key] !== undefined) tag.f[key] = updates[key];
    }
    await tag.save();
    await DictionaryUpdateModel.touch(DICTIONARIES.TAG);
    return tag;
  }

  static async remove(id) {
    const tag = await TagService.getById(id);
    await tag.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.TAG);
    return { success: true };
  }
}
