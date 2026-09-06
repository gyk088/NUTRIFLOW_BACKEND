import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';

export default class DictionaryService {
  static async getAll() {
    return DictionaryUpdateModel.getAll();
  }
}
