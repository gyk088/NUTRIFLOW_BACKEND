import IngredientModel from '../models/IngredientModel.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
import { NUTRIENT_FIELDS } from '../utils/nutrients.js';
import { DICTIONARIES } from '../utils/const.js';

const UPDATABLE_FIELDS = ['name', 'image_url', 'grams_per_unit', 'allergens', ...NUTRIENT_FIELDS];

export default class IngredientService {
  static async create(data) {
    const ingredient = new IngredientModel(data);
    await ingredient.save();
    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return ingredient;
  }

  static async getById(id) {
    const ingredient = await IngredientModel.getById(id);
    if (!ingredient) throw new Error('Ingredient not found');
    return ingredient;
  }

  static async getAll(search) {
    return search ? IngredientModel.search(search) : IngredientModel.getAll();
  }

  static async update(id, updates) {
    const ingredient = await IngredientService.getById(id);

    for (const key of UPDATABLE_FIELDS) {
      if (updates[key] !== undefined) ingredient.f[key] = updates[key];
    }
    await ingredient.save();
    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return ingredient;
  }

  static async remove(id) {
    const ingredient = await IngredientService.getById(id);
    await ingredient.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return { success: true };
  }
}
