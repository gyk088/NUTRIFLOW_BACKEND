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

  // Upserts every key/value in `dictionary` for `lang`. Rows of the language are
  // loaded once; changed ones go in one UPDATE, new ones in one INSERT, together
  // in a transaction — a failed save leaves the dictionary as it was.
  static async setDictionary(lang, dictionary) {
    await LanguageService.getByCode(lang); // throws if the language doesn't exist
    if (!dictionary || typeof dictionary !== 'object' || Array.isArray(dictionary)) {
      throw new Error('Body must be an object of key/value pairs');
    }

    const existingByKey = new Map((await AppTranslationModel.getByLanguage(lang)).map(row => [row.f.key, row]));
    const changed = [];
    const added = [];
    const now = new Date();
    for (const [key, value] of Object.entries(dictionary)) {
      const existing = existingByKey.get(key);
      if (!existing) {
        added.push({ language_code: lang, key, value });
      } else if (existing.f.value !== value) {
        existing.f.value = value;
        existing.f.utime = now; // updateMany doesn't call the model's update()
        changed.push(existing);
      }
    }

    if (changed.length || added.length) {
      await AppTranslationModel.createTransaction(async () => {
        await AppTranslationModel.updateMany(changed);
        await AppTranslationModel.insertMany(added);
      });
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
