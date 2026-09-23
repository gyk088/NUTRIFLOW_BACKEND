import LanguageModel from '../models/LanguageModel.js';
import ArticleTranslationModel from '../models/ArticleTranslationModel.js';
import TagTranslationModel from '../models/TagTranslationModel.js';
import IngredientTranslationModel from '../models/IngredientTranslationModel.js';
import RecipeTranslationModel from '../models/RecipeTranslationModel.js';

export default class LanguageService {
  static async getAll() {
    return LanguageModel.getAll();
  }

  // Используется всеми *Service как fallback-язык, когда для сущности нет
  // перевода на запрошенный клиентом язык.
  static async getDefaultCode() {
    const language = await LanguageModel.getDefault();
    if (!language) throw new Error('No default language configured');
    return language.f.code;
  }

  static async create(data) {
    const code = data.code?.toLowerCase();
    if (!code) throw new Error('code is required');

    const existing = await LanguageModel.getByCode(code);
    if (existing) throw new Error('Language with this code already exists');

    if (data.is_default) await LanguageModel.clearDefault();

    const language = new LanguageModel({ code, name: data.name, is_default: !!data.is_default });
    await language.save();
    return language;
  }

  static async getByCode(code) {
    const language = await LanguageModel.getByCode(code);
    if (!language) throw new Error('Language not found');
    return language;
  }

  static async update(code, updates) {
    const language = await LanguageService.getByCode(code);

    if (updates.name !== undefined) language.f.name = updates.name;

    if (updates.is_default === true && !language.f.is_default) {
      await LanguageModel.clearDefault();
      language.f.is_default = true;
    } else if (updates.is_default === false && language.f.is_default) {
      throw new Error('Cannot unset the default language directly — set another language as default instead');
    }

    await language.save();
    return language;
  }

  static async remove(code) {
    const language = await LanguageService.getByCode(code);
    if (language.f.is_default) throw new Error('Cannot delete the default language');

    const [articles, tags, ingredients, recipes] = await Promise.all([
      ArticleTranslationModel.select('WHERE language_code = $1 LIMIT 1', [code]),
      TagTranslationModel.select('WHERE language_code = $1 LIMIT 1', [code]),
      IngredientTranslationModel.select('WHERE language_code = $1 LIMIT 1', [code]),
      RecipeTranslationModel.select('WHERE language_code = $1 LIMIT 1', [code])
    ]);
    if (articles.length || tags.length || ingredients.length || recipes.length) {
      throw new Error('Cannot delete a language that still has translations — remove them first');
    }

    await language.delete();
    return { success: true };
  }
}
