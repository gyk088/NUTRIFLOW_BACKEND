import TagModel from '../models/TagModel.js';
import TagTranslationModel from '../models/TagTranslationModel.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
import LanguageService from './LanguageService.js';
import { pickTranslation } from '../utils/translation.js';
import { DICTIONARIES } from '../utils/const.js';

function toResolved(tag, translation, allTranslations) {
  return {
    id: tag.f.id,
    type: tag.f.type,
    name: translation.f.name,
    language: translation.f.language_code,
    availableLanguages: allTranslations.map(t => t.f.language_code),
    ctime: tag.f.ctime,
    utime: tag.f.utime
  };
}

export default class TagService {
  // languageCode/name — язык и название первого перевода, создаваемого вместе с тегом.
  static async create(languageCode, type, name) {
    const existing = await TagTranslationModel.getByTypeLanguageAndName(type, languageCode, name);
    if (existing) throw new Error('Tag with this type/name already exists for this language');

    const tag = new TagModel({ type });
    await tag.save();

    try {
      const translation = new TagTranslationModel({ tag_id: tag.f.id, language_code: languageCode, name });
      await translation.save();
    } catch (error) {
      await TagTranslationModel.deleteByTagId(tag.f.id);
      await tag.delete();
      throw error;
    }

    await DictionaryUpdateModel.touch(DICTIONARIES.TAG);
    return TagService.getFullById(tag.f.id, languageCode);
  }

  static async getById(id) {
    const tag = await TagModel.getById(id);
    if (!tag) throw new Error('Tag not found');
    return tag;
  }

  static async getFullById(id, lang) {
    const tag = await TagService.getById(id);
    const translations = await TagTranslationModel.getByTagId(id);
    if (!translations.length) throw new Error('Tag has no translations');

    const defaultLang = await LanguageService.getDefaultCode();
    const translation = pickTranslation(translations, lang, defaultLang);
    return toResolved(tag, translation, translations);
  }

  // Резолвит сразу несколько тегов на нужный язык одним проходом — используется
  // Article/Recipe/IngredientService, чтобы не дёргать БД в цикле на каждый тег.
  static async getManyResolved(tagIds, lang) {
    if (!tagIds.length) return [];
    const [tags, translations, defaultLang] = await Promise.all([
      TagModel.getByIds(tagIds),
      TagTranslationModel.getByTagIds(tagIds),
      LanguageService.getDefaultCode()
    ]);

    const translationsByTag = new Map();
    for (const t of translations) {
      const list = translationsByTag.get(t.f.tag_id) || [];
      list.push(t);
      translationsByTag.set(t.f.tag_id, list);
    }

    return tags.map(tag => {
      const tagTranslations = translationsByTag.get(tag.f.id) || [];
      const translation = pickTranslation(tagTranslations, lang, defaultLang);
      return toResolved(tag, translation, tagTranslations);
    });
  }

  static async getAll(type, lang) {
    const tags = await TagModel.getAll(type);
    const defaultLang = await LanguageService.getDefaultCode();
    const translations = await TagTranslationModel.getByTagIds(tags.map(t => t.f.id));

    const translationsByTag = new Map();
    for (const t of translations) {
      const list = translationsByTag.get(t.f.tag_id) || [];
      list.push(t);
      translationsByTag.set(t.f.tag_id, list);
    }

    return tags.map(tag => {
      const tagTranslations = translationsByTag.get(tag.f.id) || [];
      const translation = pickTranslation(tagTranslations, lang, defaultLang);
      return toResolved(tag, translation, tagTranslations);
    });
  }

  // Для формы редактирования в админке — все переводы сразу, без резолва
  // под один язык (в отличие от getFullById/getAll, которые отдают мобильному
  // приложению одну строку на нужном языке с fallback).
  static async getAdminDetail(id) {
    const tag = await TagService.getById(id);
    const translations = await TagTranslationModel.getByTagId(id);
    return {
      id: tag.f.id,
      type: tag.f.type,
      ctime: tag.f.ctime,
      utime: tag.f.utime,
      translations: translations.map(t => ({ language_code: t.f.language_code, name: t.f.name }))
    };
  }

  static async update(id, updates) {
    const tag = await TagService.getById(id);
    if (updates.type !== undefined) tag.f.type = updates.type;
    await tag.save();
    await DictionaryUpdateModel.touch(DICTIONARIES.TAG);
    return tag;
  }

  static async addTranslation(tagId, languageCode, name) {
    const tag = await TagService.getById(tagId);

    const existing = await TagTranslationModel.getByTagIdAndLanguage(tagId, languageCode);
    if (existing) {
      existing.f.name = name;
      await existing.save();
    } else {
      const translation = new TagTranslationModel({ tag_id: tag.f.id, language_code: languageCode, name });
      await translation.save();
    }

    await DictionaryUpdateModel.touch(DICTIONARIES.TAG);
    return TagService.getFullById(tagId, languageCode);
  }

  static async removeTranslation(tagId, languageCode) {
    const translations = await TagTranslationModel.getByTagId(tagId);
    if (translations.length <= 1) throw new Error('Cannot remove the last translation of a tag');

    const translation = translations.find(t => t.f.language_code === languageCode);
    if (!translation) throw new Error('Translation not found');

    await translation.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.TAG);
    return { success: true };
  }

  static async remove(id) {
    const tag = await TagService.getById(id);
    await TagTranslationModel.deleteByTagId(id);
    await tag.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.TAG);
    return { success: true };
  }
}
