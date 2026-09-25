import ArticleModel from '../models/ArticleModel.js';
import ArticleTranslationModel from '../models/ArticleTranslationModel.js';
import ArticleTagModel from '../models/ArticleTagModel.js';
import ArticleFavoriteModel from '../models/ArticleFavoriteModel.js';
import TagService from './TagService.js';
import LanguageService from './LanguageService.js';
import { pickTranslation, MissingTranslationsError, resolveAll } from '../utils/translation.js';

async function saveTags(articleId, tagIds) {
  for (const tagId of tagIds) {
    const link = new ArticleTagModel({ article_id: articleId, tag_id: tagId });
    await link.save();
  }
}

export default class ArticleService {
  // languageCode — язык первого перевода. translationData — {title, content}.
  static async create(languageCode, translationData, baseData, tagIds = []) {
    const article = new ArticleModel(baseData);
    await article.save();

    try {
      const translation = new ArticleTranslationModel({ article_id: article.f.id, language_code: languageCode, ...translationData });
      await translation.save();
      await saveTags(article.f.id, tagIds);
    } catch (error) {
      // Pool выдаёт по соединению на каждый query(), так что настоящей
      // SQL-транзакции здесь не выйдет — откатываем связи вручную.
      await ArticleTranslationModel.deleteByArticleId(article.f.id);
      await ArticleTagModel.deleteByArticleId(article.f.id);
      await article.delete();
      throw error;
    }

    return ArticleService.getFullById(article.f.id, languageCode, null);
  }

  static async getById(id) {
    const article = await ArticleModel.getById(id);
    if (!article) throw new Error('Article not found');
    return article;
  }

  static async getFullById(id, lang, userId) {
    const article = await ArticleService.getById(id);

    const translations = await ArticleTranslationModel.getByArticleId(id);
    if (!translations.length) throw new MissingTranslationsError('Article has no translations');
    const defaultLang = await LanguageService.getDefaultCode();
    const translation = pickTranslation(translations, lang, defaultLang);

    const articleTags = await ArticleTagModel.getByArticleId(id);
    const tags = await TagService.getManyResolved(articleTags.map(at => at.f.tag_id), lang);

    const result = {
      ...article.toJSON(),
      title: translation.f.title,
      content: translation.f.content,
      language: translation.f.language_code,
      availableLanguages: translations.map(t => t.f.language_code),
      tags
    };
    if (userId) {
      const favorite = await ArticleFavoriteModel.getByUserAndArticle(userId, id);
      result.isFavorite = !!favorite;
    }
    return result;
  }

  // Для формы редактирования в админке — все переводы сразу.
  static async getAdminDetail(id) {
    const article = await ArticleService.getById(id);
    const translations = await ArticleTranslationModel.getByArticleId(id);
    const articleTags = await ArticleTagModel.getByArticleId(id);

    return {
      ...article.toJSON(),
      translations: translations.map(t => ({ language_code: t.f.language_code, title: t.f.title, content: t.f.content })),
      tagIds: articleTags.map(at => at.f.tag_id)
    };
  }

  static async getAll(lang, search, userId) {
    let ids = null;
    if (search) ids = await ArticleTranslationModel.searchArticleIds(search);

    const articles = ids ? await ArticleModel.getByIds(ids) : await ArticleModel.getAll();
    return resolveAll(articles, article => ArticleService.getFullById(article.f.id, lang, userId));
  }

  static async addTranslation(articleId, languageCode, { title, content }) {
    const article = await ArticleService.getById(articleId);

    const existing = await ArticleTranslationModel.getByArticleIdAndLanguage(articleId, languageCode);
    if (existing) {
      existing.f.title = title;
      existing.f.content = content;
      await existing.save();
    } else {
      const translation = new ArticleTranslationModel({ article_id: article.f.id, language_code: languageCode, title, content });
      await translation.save();
    }

    return ArticleService.getFullById(articleId, languageCode, null);
  }

  static async removeTranslation(articleId, languageCode) {
    const translations = await ArticleTranslationModel.getByArticleId(articleId);
    if (translations.length <= 1) throw new Error('Cannot remove the last translation of an article');

    const translation = translations.find(t => t.f.language_code === languageCode);
    if (!translation) throw new Error('Translation not found');

    await translation.delete();
    return { success: true };
  }

  static async update(id, baseUpdates, tagIds) {
    const article = await ArticleService.getById(id);
    if (baseUpdates.image_url !== undefined) article.f.image_url = baseUpdates.image_url;
    await article.save();

    if (tagIds) {
      await ArticleTagModel.deleteByArticleId(id);
      await saveTags(id, tagIds);
    }
    return ArticleService.getFullById(id, null, null);
  }

  static async remove(id) {
    const article = await ArticleService.getById(id);
    await ArticleTranslationModel.deleteByArticleId(id);
    await ArticleTagModel.deleteByArticleId(id);
    await ArticleFavoriteModel.deleteByArticleId(id);
    await article.delete();
    return { success: true };
  }

  static async addFavorite(userId, articleId) {
    await ArticleService.getById(articleId);

    const existing = await ArticleFavoriteModel.getByUserAndArticle(userId, articleId);
    if (!existing) {
      const favorite = new ArticleFavoriteModel({ user_id: userId, article_id: articleId });
      await favorite.save();
    }
    return { success: true };
  }

  static async removeFavorite(userId, articleId) {
    const existing = await ArticleFavoriteModel.getByUserAndArticle(userId, articleId);
    if (existing) await existing.delete();
    return { success: true };
  }

  static async getFavorites(userId, lang) {
    const favorites = await ArticleFavoriteModel.getByUserId(userId);
    return resolveAll(favorites, f => ArticleService.getFullById(f.f.article_id, lang, userId));
  }
}
