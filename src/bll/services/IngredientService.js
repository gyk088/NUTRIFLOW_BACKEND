import IngredientModel from '../models/IngredientModel.js';
import IngredientTranslationModel from '../models/IngredientTranslationModel.js';
import IngredientTagModel from '../models/IngredientTagModel.js';
import TagService from './TagService.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
import LanguageService from './LanguageService.js';
import { pickTranslation } from '../utils/translation.js';
import { NUTRIENT_FIELDS } from '../utils/nutrients.js';
import { DICTIONARIES } from '../utils/const.js';

const UPDATABLE_FIELDS = ['image_url', 'grams_per_unit', ...NUTRIENT_FIELDS];

async function saveTags(ingredientId, tagIds) {
  for (const tagId of tagIds) {
    const link = new IngredientTagModel({ ingredient_id: ingredientId, tag_id: tagId });
    await link.save();
  }
}

export default class IngredientService {
  // languageCode/name — язык и название первого перевода, создаваемого вместе с ингредиентом.
  static async create(languageCode, name, data, tagIds = []) {
    const ingredient = new IngredientModel(data);
    await ingredient.save();

    try {
      const translation = new IngredientTranslationModel({ ingredient_id: ingredient.f.id, language_code: languageCode, name });
      await translation.save();
      await saveTags(ingredient.f.id, tagIds);
    } catch (error) {
      await IngredientTranslationModel.deleteByIngredientId(ingredient.f.id);
      await IngredientTagModel.deleteByIngredientId(ingredient.f.id);
      await ingredient.delete();
      throw error;
    }

    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return IngredientService.getFullById(ingredient.f.id, languageCode);
  }

  static async getById(id) {
    const ingredient = await IngredientModel.getById(id);
    if (!ingredient) throw new Error('Ingredient not found');
    return ingredient;
  }

  static async getFullById(id, lang) {
    const ingredient = await IngredientService.getById(id);
    const translations = await IngredientTranslationModel.getByIngredientId(id);
    if (!translations.length) throw new Error('Ingredient has no translations');

    const defaultLang = await LanguageService.getDefaultCode();
    const translation = pickTranslation(translations, lang, defaultLang);

    const ingredientTags = await IngredientTagModel.getByIngredientId(id);
    const tags = await TagService.getManyResolved(ingredientTags.map(it => it.f.tag_id), lang);

    return {
      ...ingredient.toJSON(),
      name: translation.f.name,
      language: translation.f.language_code,
      availableLanguages: translations.map(t => t.f.language_code),
      tags
    };
  }

  // Для формы редактирования в админке — все переводы сразу.
  static async getAdminDetail(id) {
    const ingredient = await IngredientService.getById(id);
    const translations = await IngredientTranslationModel.getByIngredientId(id);
    const ingredientTags = await IngredientTagModel.getByIngredientId(id);

    return {
      ...ingredient.toJSON(),
      translations: translations.map(t => ({ language_code: t.f.language_code, name: t.f.name })),
      tagIds: ingredientTags.map(it => it.f.tag_id)
    };
  }

  static async getAll(search, lang) {
    let ids = null;
    if (search) ids = await IngredientTranslationModel.searchIngredientIds(search);

    const ingredients = ids ? await IngredientModel.getByIds(ids) : await IngredientModel.getAll();
    return Promise.all(ingredients.map(ingredient => IngredientService.getFullById(ingredient.f.id, lang)));
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
    return IngredientService.getFullById(id, null);
  }

  static async addTranslation(ingredientId, languageCode, name) {
    const ingredient = await IngredientService.getById(ingredientId);

    const existing = await IngredientTranslationModel.getByIngredientIdAndLanguage(ingredientId, languageCode);
    if (existing) {
      existing.f.name = name;
      await existing.save();
    } else {
      const translation = new IngredientTranslationModel({ ingredient_id: ingredient.f.id, language_code: languageCode, name });
      await translation.save();
    }

    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return IngredientService.getFullById(ingredientId, languageCode);
  }

  static async removeTranslation(ingredientId, languageCode) {
    const translations = await IngredientTranslationModel.getByIngredientId(ingredientId);
    if (translations.length <= 1) throw new Error('Cannot remove the last translation of an ingredient');

    const translation = translations.find(t => t.f.language_code === languageCode);
    if (!translation) throw new Error('Translation not found');

    await translation.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return { success: true };
  }

  static async remove(id) {
    const ingredient = await IngredientService.getById(id);
    await IngredientTranslationModel.deleteByIngredientId(id);
    await IngredientTagModel.deleteByIngredientId(id);
    await ingredient.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
    return { success: true };
  }
}
