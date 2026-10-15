import AppTranslationModel from '../models/AppTranslationModel.js';
import LanguageService from './LanguageService.js';

export default class AppTranslationService {
  // Flat { "common.back": "Назад", ... } for the requested language, with the
  // default language's value used per-key when the requested language is
  // missing that specific key (not an all-or-nothing fallback — a partially
  // translated language still returns every key it can).
  static async getDictionary(lang) {
    const defaultLang = await LanguageService.getDefaultCode();
    const [defaultRows, langRows] = lang && lang !== defaultLang
      ? await Promise.all([AppTranslationModel.getByLanguage(defaultLang), AppTranslationModel.getByLanguage(lang)])
      : [await AppTranslationModel.getByLanguage(defaultLang), []];

    const dictionary = {};
    for (const row of defaultRows) dictionary[row.f.key] = row.f.value;
    for (const row of langRows) dictionary[row.f.key] = row.f.value;
    return dictionary;
  }

  // Admin's own view of one language — no fallback merging, just what's
  // actually stored for it (so a blank/missing key is visible as such).
  static async getAdminDictionary(lang) {
    const rows = await AppTranslationModel.getByLanguage(lang);
    const dictionary = {};
    for (const row of rows) dictionary[row.f.key] = row.f.value;
    return dictionary;
  }

  // Upserts every key/value in `dictionary` for `lang`. Sequential by design,
  // same as the rest of the codebase's save-composition loops (see
  // RecipeService.saveComposition) — simple over fast, this isn't hot path.
  static async setDictionary(lang, dictionary) {
    await LanguageService.getByCode(lang); // throws if the language doesn't exist

    for (const [key, value] of Object.entries(dictionary)) {
      const existing = await AppTranslationModel.getByLanguageAndKey(lang, key);
      if (existing) {
        existing.f.value = value;
        await existing.save();
      } else {
        const row = new AppTranslationModel({ language_code: lang, key, value });
        await row.save();
      }
    }

    return AppTranslationService.getAdminDictionary(lang);
  }

  static async removeKey(lang, key) {
    const existing = await AppTranslationModel.getByLanguageAndKey(lang, key);
    if (!existing) throw new Error('Translation key not found for this language');
    await existing.delete();
    return { success: true };
  }
}
