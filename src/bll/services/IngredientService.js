import IngredientModel from '../models/IngredientModel.js';
import IngredientTagModel from '../models/IngredientTagModel.js';
import TagModel from '../models/TagModel.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
import { NUTRIENT_FIELDS } from '../utils/nutrients.js';
import { DICTIONARIES } from '../utils/const.js';

const UPDATABLE_FIELDS = ['name_ru', 'name_en', 'image_url', 'grams_per_unit', ...NUTRIENT_FIELDS];

async function saveTags(ingredientId, tagIds) {
  for (const tagId of tagIds) {
    const link = new IngredientTagModel({ ingredient_id: ingredientId, tag_id: tagId });
    await link.save();
  }
}

export default class IngredientService {
  static async create(data, tagIds = []) {
    const ingredient = new IngredientModel(data);
    await ingredient.save();
    await saveTags(ingredient.f.id, tagIds);
    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return IngredientService.getFullById(ingredient.f.id);
  }

  static async getById(id) {
    const ingredient = await IngredientModel.getById(id);
    if (!ingredient) throw new Error('Ingredient not found');
    return ingredient;
  }

  static async getFullById(id) {
    const ingredient = await IngredientService.getById(id);

    const ingredientTags = await IngredientTagModel.getByIngredientId(id);
    const tags = await TagModel.getByIds(ingredientTags.map(it => it.f.tag_id));

    return { ...ingredient.toJSON(), tags: tags.map(t => t.toJSON()) };
  }

  static async getAll(search) {
    return search ? IngredientModel.search(search) : IngredientModel.getAll();
  }

  static async update(id, updates, tagIds) {
    const ingredient = await IngredientService.getById(id);

    for (const key of UPDATABLE_FIELDS) {
      if (updates[key] !== undefined) ingredient.f[key] = updates[key];
    }
    await ingredient.save();

    if (tagIds) {
      await IngredientTagModel.deleteByIngredientId(id);
      await saveTags(id, tagIds);
    }

    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return IngredientService.getFullById(id);
  }

  static async remove(id) {
    const ingredient = await IngredientService.getById(id);
    await IngredientTagModel.deleteByIngredientId(id);
    await ingredient.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return { success: true };
  }
}
