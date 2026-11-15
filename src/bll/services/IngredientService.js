import IngredientModel from '../models/IngredientModel.js';
import IngredientTranslationModel from '../models/IngredientTranslationModel.js';
import IngredientTagModel from '../models/IngredientTagModel.js';
import RecipeModel from '../models/RecipeModel.js';
import RecipeTranslationModel from '../models/RecipeTranslationModel.js';
import TagService from './TagService.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
import LanguageService from './LanguageService.js';
import { pickTranslation, MissingTranslationsError } from '../utils/translation.js';
import { NUTRIENT_FIELDS, stripNutrients } from '../utils/nutrients.js';
import { DICTIONARIES, MEASURE_UNITS, UNIT_TO_GRAMS } from '../utils/const.js';
import { isVisibleTo, assertOwnPrivate, NotFoundError, loadAuthors, loadAuthor, toNonNegativeNumber } from '../utils/ownership.js';
import { groupBy } from '../utils/helpers.js';

const UPDATABLE_FIELDS = ['image_url', 'grams_per_unit', 'default_unit', ...NUTRIENT_FIELDS];

// Сколько личных ингредиентов может завести один пользователь приложения.
const MAX_USER_INGREDIENTS = 1000;
const MAX_NAME_LENGTH = 100;

// Единица по умолчанию должна быть известной, а для не-весовой (piece, tbsp...)
// нужен вес в граммах в grams_per_unit — иначе КБЖУ рецепта не посчитать.
function validateUnit(defaultUnit, gramsPerUnit) {
  if (defaultUnit === undefined || defaultUnit === null) return;
  if (!MEASURE_UNITS.includes(defaultUnit)) {
    throw new Error(`default_unit must be one of: ${MEASURE_UNITS.join(', ')}`);
  }
  if (UNIT_TO_GRAMS[defaultUnit] === undefined && !Number(gramsPerUnit?.[defaultUnit])) {
    throw new Error(`grams_per_unit must define the weight in grams of one "${defaultUnit}"`);
  }
}

function pickFields(data) {
  const picked = {};
  for (const key of UPDATABLE_FIELDS) {
    if (data[key] !== undefined) picked[key] = data[key];
  }
  return picked;
}

// Данные от мобильного приложения проверяем строже, чем из админки: только
// известные поля, числа >= 0, grams_per_unit — { <единица>: граммы > 0 }.
function sanitizeUserFields(data) {
  const picked = pickFields(data);
  for (const field of NUTRIENT_FIELDS) {
    if (picked[field] !== undefined) picked[field] = toNonNegativeNumber(picked[field], field);
  }
  if (picked.grams_per_unit !== undefined) {
    const gpu = picked.grams_per_unit;
    if (gpu === null || typeof gpu !== 'object' || Array.isArray(gpu)) throw new Error('grams_per_unit must be an object');
    const clean = {};
    for (const [unit, grams] of Object.entries(gpu)) {
      if (!MEASURE_UNITS.includes(unit)) throw new Error(`grams_per_unit: unknown unit "${unit}"`);
      const value = toNonNegativeNumber(grams, `grams_per_unit.${unit}`);
      if (value > 0) clean[unit] = value;
    }
    picked.grams_per_unit = clean;
  }
  return picked;
}

function validateName(name) {
  if (typeof name !== 'string' || !name.trim()) throw new Error('name is required');
  if (name.trim().length > MAX_NAME_LENGTH) throw new Error(`name must be at most ${MAX_NAME_LENGTH} characters`);
  return name.trim();
}

async function saveTags(ingredientId, tagIds) {
  for (const tagId of tagIds) {
    const link = new IngredientTagModel({ ingredient_id: ingredientId, tag_id: tagId });
    await link.save();
  }
}

// Название/описание на одном языке: обновляет существующий перевод или
// добавляет новый.
async function upsertTranslation(ingredientId, languageCode, name, description) {
  const existing = await IngredientTranslationModel.getByIngredientIdAndLanguage(ingredientId, languageCode);
  if (existing) {
    existing.f.name = name;
    existing.f.description = description;
    await existing.save();
  } else {
    const translation = new IngredientTranslationModel({ ingredient_id: ingredientId, language_code: languageCode, name, description });
    await translation.save();
  }
}

// Изменение ингредиента меняет КБЖУ/название в ответе рецептов с ним —
// помечаем их изменёнными, чтобы /app/sync отдал их заново.
async function afterIngredientChanged(ingredientId) {
  await RecipeModel.touchByIngredientId(ingredientId);
  await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);
  await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
}

export default class IngredientService {
  // languageCode/name/description — язык и первый перевод, создаваемый вместе с ингредиентом.
  // userId — ингредиент создаёт пользователь приложения: он личный (is_public=false),
  // пока админ не добавит его в общий каталог.
  static async create(languageCode, name, data, tagIds = [], description, { userId = null } = {}) {
    const fields = userId ? sanitizeUserFields(data) : pickFields(data);
    validateUnit(fields.default_unit, fields.grams_per_unit);

    if (userId) {
      name = validateName(name);
      const own = await IngredientModel.getByUserId(userId);
      if (own.length >= MAX_USER_INGREDIENTS) throw new Error(`At most ${MAX_USER_INGREDIENTS} own ingredients`);
      Object.assign(fields, { user_id: userId, is_public: false });
    }

    const ingredient = new IngredientModel(fields);
    await ingredient.save();

    try {
      const translation = new IngredientTranslationModel({ ingredient_id: ingredient.f.id, language_code: languageCode, name, description });
      await translation.save();
      await saveTags(ingredient.f.id, tagIds || []);
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
    if (!ingredient) throw new NotFoundError('Ingredient not found');
    return ingredient;
  }

  // includeNutrition=false — для гостевого доступа (см. /app/sync): отдаёт
  // имя/изображение/единицы измерения, но без нутриентных колонок.
  // viewerId — запрос из приложения: чужой личный ингредиент = "не найден".
  static async getFullById(id, lang, { includeNutrition = true, viewerId } = {}) {
    const ingredient = await IngredientService.getById(id);
    if (viewerId !== undefined && !isVisibleTo(ingredient, viewerId)) throw new NotFoundError('Ingredient not found');

    const [full] = await IngredientService.resolveMany([ingredient], lang, { includeNutrition });
    if (!full) throw new MissingTranslationsError('Ingredient has no translations');
    return full;
  }

  // Собирает ответы для списка строк ingredient пакетно: по одному запросу на
  // переводы, связи с тегами и сами теги — независимо от длины списка
  // (раньше — ~8 запросов на КАЖДЫЙ ингредиент). Порядок сохраняется;
  // ингредиенты без единого перевода пропускаются (показать их нечем).
  static async resolveMany(ingredients, lang, { includeNutrition = true } = {}) {
    if (!ingredients.length) return [];
    const ids = ingredients.map(ingredient => ingredient.f.id);

    const [translations, links, defaultLang] = await Promise.all([
      IngredientTranslationModel.getByIngredientIds(ids),
      IngredientTagModel.getByIngredientIds(ids),
      LanguageService.getDefaultCode()
    ]);
    const tags = await TagService.getManyResolved([...new Set(links.map(link => link.f.tag_id))], lang);

    const translationsById = groupBy(translations, t => t.f.ingredient_id);
    const tagIdsById = groupBy(links, link => link.f.ingredient_id);

    const result = [];
    for (const ingredient of ingredients) {
      const own = translationsById.get(ingredient.f.id);
      if (!own) continue;
      const translation = pickTranslation(own, lang, defaultLang);
      const tagIds = new Set((tagIdsById.get(ingredient.f.id) || []).map(link => link.f.tag_id));

      const full = {
        ...ingredient.toJSON(),
        name: translation.f.name,
        description: translation.f.description,
        language: translation.f.language_code,
        availableLanguages: own.map(t => t.f.language_code),
        tags: tags.filter(tag => tagIds.has(tag.id))
      };
      result.push(includeNutrition ? full : stripNutrients(full));
    }
    return result;
  }

  // Для формы редактирования в админке — все переводы сразу (+ автор, если
  // ингредиент создан пользователем приложения).
  static async getAdminDetail(id) {
    const ingredient = await IngredientService.getById(id);
    const translations = await IngredientTranslationModel.getByIngredientId(id);
    const ingredientTags = await IngredientTagModel.getByIngredientId(id);

    return {
      ...ingredient.toJSON(),
      translations: translations.map(t => ({ language_code: t.f.language_code, name: t.f.name, description: t.f.description })),
      tagIds: ingredientTags.map(it => it.f.tag_id),
      author: await loadAuthor(ingredient.f.user_id)
    };
  }

  // Каталог + (если передан viewerId) личные ингредиенты этого пользователя.
  static async getAll(search, lang, viewerId = null) {
    const ids = search ? await IngredientTranslationModel.searchIngredientIds(search) : null;
    const ingredients = await IngredientModel.getVisible(viewerId, ids);
    return IngredientService.resolveMany(ingredients, lang);
  }

  // Свои ингредиенты пользователя приложения (личные и уже добавленные в каталог).
  static async getOwn(userId, lang) {
    const ingredients = await IngredientModel.getByUserId(userId);
    return IngredientService.resolveMany(ingredients, lang);
  }

  // Для админки — ингредиенты, созданные пользователями, с автором и тем, в
  // скольких рецептах они используются. status: pending | published | all.
  static async getUserCreated(status = 'pending', search, lang) {
    const ids = search ? await IngredientTranslationModel.searchIngredientIds(search) : null;
    const ingredients = await IngredientModel.getUserCreated(status, ids);
    const [authors, usage, resolved] = await Promise.all([
      loadAuthors(ingredients),
      RecipeModel.countByIngredientIds(ingredients.map(i => i.f.id)),
      IngredientService.resolveMany(ingredients, lang)
    ]);

    return resolved.map(full => ({
      ...full,
      author: authors.get(full.user_id) || null,
      recipesCount: usage.get(full.id) || 0
    }));
  }

  static async update(id, updates, tagIds) {
    const ingredient = await IngredientService.getById(id);

    Object.assign(ingredient.f, pickFields(updates));
    validateUnit(ingredient.f.default_unit, ingredient.f.grams_per_unit);
    await ingredient.save();

    if (tagIds) {
      await IngredientTagModel.deleteByIngredientId(id);
      await saveTags(id, tagIds);
    }

    await afterIngredientChanged(id);
    return IngredientService.getFullById(id, null);
  }

  // Изменение своего личного ингредиента из приложения. body — те же поля,
  // что при создании; name/description меняют перевод на languageCode (по
  // умолчанию — на языке, на котором ингредиент создан).
  static async updateOwn(userId, id, body) {
    const ingredient = await IngredientModel.getById(id);
    assertOwnPrivate(ingredient, userId, 'Ingredient');

    const { languageCode, name, description, tagIds, ...data } = body;
    Object.assign(ingredient.f, sanitizeUserFields(data));
    validateUnit(ingredient.f.default_unit, ingredient.f.grams_per_unit);
    await ingredient.save();

    let lang = languageCode;
    if (name !== undefined || description !== undefined) {
      const translations = await IngredientTranslationModel.getByIngredientId(id);
      lang = lang || translations[0]?.f.language_code;
      if (!lang) throw new Error('languageCode is required');
      const current = translations.find(t => t.f.language_code === lang);
      const nextName = name !== undefined ? validateName(name) : current?.f.name;
      if (!nextName) throw new Error('name is required');
      await upsertTranslation(id, lang, nextName, description !== undefined ? description : current?.f.description);
    }

    if (tagIds) {
      await IngredientTagModel.deleteByIngredientId(id);
      await saveTags(id, tagIds);
    }

    await afterIngredientChanged(id);
    return IngredientService.getFullById(id, lang);
  }

  static async addTranslation(ingredientId, languageCode, name, description) {
    await IngredientService.getById(ingredientId);
    await upsertTranslation(ingredientId, languageCode, name, description);
    await afterIngredientChanged(ingredientId);
    return IngredientService.getFullById(ingredientId, languageCode);
  }

  static async removeTranslation(ingredientId, languageCode) {
    const translations = await IngredientTranslationModel.getByIngredientId(ingredientId);
    if (translations.length <= 1) throw new Error('Cannot remove the last translation of an ingredient');

    const translation = translations.find(t => t.f.language_code === languageCode);
    if (!translation) throw new Error('Translation not found');

    await translation.delete();
    await afterIngredientChanged(ingredientId);
    return { success: true };
  }

  // Мягкое удаление (deleted_at), а не DELETE — строка остаётся как tombstone
  // для /app/sync (см. CatalogSyncService), иначе устройство с локальным
  // кэшем каталога никогда не узнает, что ингредиент пропал. Переводы и
  // связи (теги, состав рецептов) не трогаем — они просто больше не
  // всплывают нигде, т.к. все чтения фильтруют deleted_at IS NULL.
  static async remove(id) {
    const ingredient = await IngredientService.getById(id);
    ingredient.f.deleted_at = new Date();
    await ingredient.save();
    await afterIngredientChanged(id);
    return { success: true };
  }

  // Удаление своего личного ингредиента из приложения. Пока он есть в
  // составе хотя бы одного рецепта — нельзя, иначе у рецепта поедет КБЖУ.
  static async removeOwn(userId, id) {
    const ingredient = await IngredientModel.getById(id);
    assertOwnPrivate(ingredient, userId, 'Ingredient');

    const recipes = await RecipeModel.getByIngredientId(id);
    if (recipes.length) {
      const names = await Promise.all(recipes.map(async r => (await RecipeTranslationModel.getByRecipeId(r.f.id))[0]?.f.name || r.f.id));
      const error = new Error(`Ingredient is used in recipes: ${names.join(', ')}`);
      error.code = 'INGREDIENT_IN_USE';
      error.recipeIds = recipes.map(r => r.f.id);
      throw error;
    }

    return IngredientService.remove(id);
  }

  // Админ добавляет пользовательский ингредиент в общий каталог: тот же id,
  // теперь виден всем (в /app/sync он придёт всем как изменённый).
  static async publish(id) {
    const ingredient = await IngredientService.getById(id);
    if (ingredient.f.is_public) return IngredientService.getAdminDetail(id);

    ingredient.f.is_public = true;
    ingredient.f.published_at = new Date();
    await ingredient.save();

    await afterIngredientChanged(id);
    return IngredientService.getAdminDetail(id);
  }
}
