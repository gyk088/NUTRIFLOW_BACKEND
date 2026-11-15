import RecipeModel from '../models/RecipeModel.js';
import RecipeTranslationModel from '../models/RecipeTranslationModel.js';
import RecipeIngredientModel from '../models/RecipeIngredientModel.js';
import RecipeTagModel from '../models/RecipeTagModel.js';
import IngredientModel from '../models/IngredientModel.js';
import IngredientTranslationModel from '../models/IngredientTranslationModel.js';
import TagService from './TagService.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
import LanguageService from './LanguageService.js';
import { pickTranslation, MissingTranslationsError } from '../utils/translation.js';
import { NUTRIENT_FIELDS, stripNutrients } from '../utils/nutrients.js';
import { DICTIONARIES, UNIT_TO_GRAMS } from '../utils/const.js';
import { isVisibleTo, assertOwnPrivate, NotFoundError, loadAuthors, loadAuthor, toNonNegativeNumber } from '../utils/ownership.js';
import { groupBy } from '../utils/helpers.js';

const BASE_FIELDS = ['image_url', 'servings'];
const TRANSLATION_FIELDS = ['name', 'description', 'cook_time', 'steps'];

// Сколько личных рецептов может завести один пользователь приложения
// (как и прежний лимит preferences.myRecipes).
const MAX_USER_RECIPES = 500;
const MAX_NAME_LENGTH = 150;

// Переводит quantity/unit строки состава в граммы. Для весовых/объёмных
// единиц — прямой коэффициент, для штучных (piece, tbsp...) — через
// ingredient.grams_per_unit, как описано в install/steps/2.sql.
function toGrams(ingredient, quantity, unit) {
  if (UNIT_TO_GRAMS[unit] !== undefined) {
    return quantity * UNIT_TO_GRAMS[unit];
  }

  const gramsPerUnit = ingredient.f.grams_per_unit?.[unit];
  if (!gramsPerUnit) {
    throw new Error(`No gram conversion for unit "${unit}" on ingredient "${ingredient.f.id}"`);
  }
  return quantity * gramsPerUnit;
}

function round2(value) {
  return Math.round(value * 100) / 100;
}

function sumNutrition(compositionRows, ingredientsById) {
  const totals = {};
  for (const field of NUTRIENT_FIELDS) totals[field] = 0;

  for (const row of compositionRows) {
    const ingredient = ingredientsById.get(row.f.ingredient_id);
    if (!ingredient) continue;

    const grams = toGrams(ingredient, Number(row.f.quantity), row.f.unit);
    const factor = grams / 100;
    for (const field of NUTRIENT_FIELDS) {
      totals[field] += Number(ingredient.f[field] || 0) * factor;
    }
  }

  return totals;
}

// Резолвит названия сразу нескольких ингредиентов на нужный язык — используется
// для состава рецепта, где полноценный IngredientService.getFullById (с тегами)
// был бы избыточен.
async function resolveIngredientNames(ingredientIds, lang) {
  if (!ingredientIds.length) return new Map();

  const [translations, defaultLang] = await Promise.all([
    IngredientTranslationModel.getByIngredientIds(ingredientIds),
    LanguageService.getDefaultCode()
  ]);

  const byIngredient = new Map();
  for (const t of translations) {
    const list = byIngredient.get(t.f.ingredient_id) || [];
    list.push(t);
    byIngredient.set(t.f.ingredient_id, list);
  }

  const result = new Map();
  for (const id of ingredientIds) {
    const translation = pickTranslation(byIngredient.get(id) || [], lang, defaultLang);
    result.set(id, translation?.f.name || null);
  }
  return result;
}

async function saveComposition(recipeId, ingredients, tagIds) {
  for (const item of ingredients) {
    const link = new RecipeIngredientModel({
      recipe_id: recipeId,
      ingredient_id: item.ingredient_id,
      quantity: item.quantity,
      unit: item.unit || 'g'
    });
    await link.save();
  }

  for (const tagId of tagIds) {
    const link = new RecipeTagModel({ recipe_id: recipeId, tag_id: tagId });
    await link.save();
  }
}

function pickBase(data) {
  const picked = {};
  for (const key of BASE_FIELDS) {
    if (data?.[key] !== undefined) picked[key] = data[key];
  }
  return picked;
}

function validateServings(base) {
  if (base.servings === undefined) return;
  const servings = Number(base.servings);
  if (!Number.isInteger(servings) || servings < 1 || servings > 100) throw new Error('servings must be an integer from 1 to 100');
  base.servings = servings;
}

// Состав проверяем ДО записи: ингредиент существует и не удалён, его можно
// использовать в этом рецепте, единицу можно перевести в граммы, без дублей.
// В рецепт каталога (isPublic) — только ингредиенты каталога, иначе
// остальные пользователи получат рецепт со "скрытым" ингредиентом. В
// личный рецепт — каталог + личные ингредиенты автора рецепта (ownerId).
async function validateComposition(items, { isPublic, ownerId }) {
  if (!Array.isArray(items)) throw new Error('ingredients must be an array');

  const ids = items.map(item => item?.ingredient_id);
  if (ids.some(id => typeof id !== 'string' || !id)) throw new Error('each ingredient needs ingredient_id');
  if (new Set(ids).size !== ids.length) throw new Error('an ingredient can appear in a recipe only once');

  const found = await IngredientModel.getByIds(ids);
  const byId = new Map(found.map(ing => [ing.f.id, ing]));

  return items.map(item => {
    const ingredient = byId.get(item.ingredient_id);
    const allowed = ingredient && (ingredient.f.is_public || (!isPublic && ownerId && ingredient.f.user_id === ownerId));
    if (!allowed) {
      if (ingredient && isPublic) throw new Error(`Ingredient "${item.ingredient_id}" is not in the shared catalog yet — publish it first`);
      throw new Error(`Ingredient "${item.ingredient_id}" not found`);
    }
    const quantity = toNonNegativeNumber(item.quantity, 'quantity');
    if (quantity === 0) throw new Error('quantity must be greater than 0');
    const unit = item.unit || 'g';
    toGrams(ingredient, quantity, unit);
    return { ingredient_id: item.ingredient_id, quantity, unit };
  });
}

function validateRecipeName(name) {
  if (typeof name !== 'string' || !name.trim()) throw new Error('name is required');
  if (name.trim().length > MAX_NAME_LENGTH) throw new Error(`name must be at most ${MAX_NAME_LENGTH} characters`);
  return name.trim();
}

export default class RecipeService {
  // languageCode — язык первого перевода. translationData — {name, description, cook_time, steps}.
  // userId — рецепт создаёт пользователь приложения: он личный (is_public=false),
  // пока админ не добавит его в общий каталог.
  static async create(languageCode, translationData, baseData, ingredients = [], tagIds = [], { userId = null } = {}) {
    const base = pickBase(baseData);
    validateServings(base);
    if (userId) {
      translationData = { ...translationData, name: validateRecipeName(translationData?.name) };
      const own = await RecipeModel.getByUserId(userId);
      if (own.length >= MAX_USER_RECIPES) throw new Error(`At most ${MAX_USER_RECIPES} own recipes`);
      Object.assign(base, { user_id: userId, is_public: false });
    }
    const composition = await validateComposition(ingredients || [], { isPublic: !userId, ownerId: userId });

    const recipe = new RecipeModel(base);
    await recipe.save();

    try {
      const translation = new RecipeTranslationModel({ recipe_id: recipe.f.id, language_code: languageCode, ...translationData });
      await translation.save();
      await saveComposition(recipe.f.id, composition, tagIds || []);
    } catch (error) {
      // Pool выдаёт по соединению на каждый query(), так что настоящей
      // SQL-транзакции здесь не выйдет — откатываем состав вручную.
      await RecipeTranslationModel.deleteByRecipeId(recipe.f.id);
      await RecipeIngredientModel.deleteByRecipeId(recipe.f.id);
      await RecipeTagModel.deleteByRecipeId(recipe.f.id);
      await recipe.delete();
      throw error;
    }

    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return RecipeService.getFullById(recipe.f.id, languageCode);
  }

  static async getById(id) {
    const recipe = await RecipeModel.getById(id);
    if (!recipe) throw new NotFoundError('Recipe not found');
    return recipe;
  }

  // includeNutrition=false — для гостевого доступа (см. /app/sync): состав
  // рецепта (имена/граммовки) остаётся, но без КБЖУ и без нутриентных
  // колонок в каждом вложенном ingredient.
  // viewerId — запрос из приложения: чужой личный рецепт = "не найден".
  static async getFullById(id, lang, { includeNutrition = true, viewerId } = {}) {
    const recipe = await RecipeService.getById(id);
    if (viewerId !== undefined && !isVisibleTo(recipe, viewerId)) throw new NotFoundError('Recipe not found');

    const [full] = await RecipeService.resolveMany([recipe], lang, { includeNutrition });
    if (!full) throw new MissingTranslationsError('Recipe has no translations');
    return full;
  }

  // Собирает ответы для списка строк recipe пакетно: переводы, состав,
  // ингредиенты состава и их названия, теги — по одному запросу на таблицу
  // независимо от длины списка (раньше — ~12 запросов на КАЖДЫЙ рецепт).
  // Порядок сохраняется; рецепты без единого перевода пропускаются.
  static async resolveMany(recipes, lang, { includeNutrition = true } = {}) {
    if (!recipes.length) return [];
    const ids = recipes.map(recipe => recipe.f.id);

    const [translations, composition, recipeTags, defaultLang] = await Promise.all([
      RecipeTranslationModel.getByRecipeIds(ids),
      RecipeIngredientModel.getByRecipeIds(ids),
      RecipeTagModel.getByRecipeIds(ids),
      LanguageService.getDefaultCode()
    ]);

    const ingredientIds = [...new Set(composition.map(row => row.f.ingredient_id))];
    const [ingredients, ingredientTranslations, tags] = await Promise.all([
      IngredientModel.getByIds(ingredientIds),
      IngredientTranslationModel.getByIngredientIds(ingredientIds),
      TagService.getManyResolved([...new Set(recipeTags.map(rt => rt.f.tag_id))], lang)
    ]);

    const ingredientsById = new Map(ingredients.map(ing => [ing.f.id, ing]));
    const ingredientTranslationsById = groupBy(ingredientTranslations, t => t.f.ingredient_id);
    const ingredientNames = new Map(ingredientIds.map(id => [
      id,
      pickTranslation(ingredientTranslationsById.get(id) || [], lang, defaultLang)?.f.name || null
    ]));

    const translationsById = groupBy(translations, t => t.f.recipe_id);
    const compositionById = groupBy(composition, row => row.f.recipe_id);
    const tagIdsById = groupBy(recipeTags, rt => rt.f.recipe_id);

    const result = [];
    for (const recipe of recipes) {
      const own = translationsById.get(recipe.f.id);
      if (!own) continue;
      const translation = pickTranslation(own, lang, defaultLang);
      const rows = compositionById.get(recipe.f.id) || [];
      const tagIds = new Set((tagIdsById.get(recipe.f.id) || []).map(rt => rt.f.tag_id));

      let nutrition;
      if (includeNutrition) {
        const servings = recipe.f.servings || 1;
        const total = sumNutrition(rows, ingredientsById);
        const perServing = {};
        for (const field of NUTRIENT_FIELDS) {
          perServing[field] = round2(total[field] / servings);
          total[field] = round2(total[field]);
        }
        nutrition = { total, perServing };
      }

      result.push({
        ...recipe.toJSON(),
        name: translation.f.name,
        description: translation.f.description,
        cook_time: translation.f.cook_time,
        steps: translation.f.steps,
        language: translation.f.language_code,
        availableLanguages: own.map(t => t.f.language_code),
        ingredients: rows.map(row => {
          const ingredient = { ...ingredientsById.get(row.f.ingredient_id)?.toJSON(), name: ingredientNames.get(row.f.ingredient_id) };
          return {
            ingredient: includeNutrition ? ingredient : stripNutrients(ingredient),
            quantity: row.f.quantity,
            unit: row.f.unit
          };
        }),
        tags: tags.filter(tag => tagIds.has(tag.id)),
        ...(nutrition ? { nutrition } : {})
      });
    }
    return result;
  }

  // Для формы редактирования в админке — все переводы сразу (+ автор и
  // названия ингредиентов состава: личные ингредиенты пользователя не
  // входят в общий список, из которого админка берёт названия).
  static async getAdminDetail(id) {
    const recipe = await RecipeService.getById(id);
    const translations = await RecipeTranslationModel.getByRecipeId(id);
    const composition = await RecipeIngredientModel.getByRecipeId(id);
    const recipeTags = await RecipeTagModel.getByRecipeId(id);

    const ingredientIds = composition.map(row => row.f.ingredient_id);
    const ingredients = await IngredientModel.getByIds(ingredientIds);
    const ingredientsById = new Map(ingredients.map(ing => [ing.f.id, ing]));
    const ingredientNames = await resolveIngredientNames(ingredientIds, null);

    const servings = recipe.f.servings || 1;
    const total = sumNutrition(composition, ingredientsById);
    const perServing = {};
    for (const field of NUTRIENT_FIELDS) {
      perServing[field] = round2(total[field] / servings);
      total[field] = round2(total[field]);
    }

    return {
      ...recipe.toJSON(),
      translations: translations.map(t => ({
        language_code: t.f.language_code,
        name: t.f.name,
        description: t.f.description,
        cook_time: t.f.cook_time,
        steps: t.f.steps
      })),
      ingredients: composition.map(row => {
        const ingredient = ingredientsById.get(row.f.ingredient_id);
        return {
          ingredient_id: row.f.ingredient_id,
          quantity: row.f.quantity,
          unit: row.f.unit,
          name: ingredientNames.get(row.f.ingredient_id),
          default_unit: ingredient?.f.default_unit,
          is_public: ingredient ? ingredient.f.is_public : null
        };
      }),
      tagIds: recipeTags.map(rt => rt.f.tag_id),
      nutrition: { total, perServing },
      author: await loadAuthor(recipe.f.user_id)
    };
  }

  // Каталог + (если передан viewerId) личные рецепты этого пользователя.
  static async getAll(search, lang, viewerId = null) {
    const ids = search ? await RecipeTranslationModel.searchRecipeIds(search) : null;
    const recipes = await RecipeModel.getVisible(viewerId, ids);
    return RecipeService.resolveMany(recipes, lang);
  }

  // Свои рецепты пользователя приложения (личные и уже добавленные в каталог).
  static async getOwn(userId, lang) {
    const recipes = await RecipeModel.getByUserId(userId);
    return RecipeService.resolveMany(recipes, lang);
  }

  // Для админки — рецепты, созданные пользователями, с автором и списком
  // ещё личных ингредиентов состава (они уйдут в каталог вместе с рецептом).
  static async getUserCreated(status = 'pending', search, lang) {
    const ids = search ? await RecipeTranslationModel.searchRecipeIds(search) : null;
    const recipes = await RecipeModel.getUserCreated(status, ids);
    const [authors, resolved] = await Promise.all([loadAuthors(recipes), RecipeService.resolveMany(recipes, lang)]);

    return resolved.map(full => ({
      ...full,
      author: authors.get(full.user_id) || null,
      privateIngredients: full.ingredients
        .filter(item => item.ingredient.is_public === false)
        .map(item => ({ id: item.ingredient.id, name: item.ingredient.name }))
    }));
  }

  static async update(id, baseUpdates, ingredients, tagIds) {
    const recipe = await RecipeService.getById(id);

    const base = pickBase(baseUpdates);
    validateServings(base);
    const composition = ingredients
      ? await validateComposition(ingredients, { isPublic: recipe.f.is_public, ownerId: recipe.f.user_id })
      : null;

    Object.assign(recipe.f, base);
    recipe.f.utime = new Date();
    await recipe.save();

    if (composition) {
      await RecipeIngredientModel.deleteByRecipeId(id);
    }
    if (tagIds) {
      await RecipeTagModel.deleteByRecipeId(id);
    }
    await saveComposition(id, composition || [], tagIds || []);

    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return RecipeService.getFullById(id, null);
  }

  // Изменение своего личного рецепта из приложения. body — как при создании:
  // { languageCode?, name?, description?, cook_time?, steps?, servings?,
  //   image_url?, ingredients?, tagIds? }. Тексты меняют перевод на
  // languageCode (по умолчанию — язык, на котором рецепт создан).
  static async updateOwn(userId, id, body) {
    const recipe = await RecipeModel.getById(id);
    assertOwnPrivate(recipe, userId, 'Recipe');

    const translationData = {};
    for (const key of TRANSLATION_FIELDS) {
      if (body[key] !== undefined) translationData[key] = body[key];
    }
    if (translationData.name !== undefined) translationData.name = validateRecipeName(translationData.name);

    let lang = body.languageCode;
    if (Object.keys(translationData).length) {
      const translations = await RecipeTranslationModel.getByRecipeId(id);
      lang = lang || translations[0]?.f.language_code;
      if (!lang) throw new Error('languageCode is required');
      const current = translations.find(t => t.f.language_code === lang);
      if (!current && !translationData.name) throw new Error('name is required');
    }

    await RecipeService.update(id, body, body.ingredients, body.tagIds);
    if (Object.keys(translationData).length) await RecipeService.addTranslation(id, lang, translationData);
    return RecipeService.getFullById(id, lang);
  }

  static async addTranslation(recipeId, languageCode, translationData) {
    const recipe = await RecipeService.getById(recipeId);

    const existing = await RecipeTranslationModel.getByRecipeIdAndLanguage(recipeId, languageCode);
    if (existing) {
      Object.assign(existing.f, translationData);
      await existing.save();
    } else {
      const translation = new RecipeTranslationModel({ recipe_id: recipe.f.id, language_code: languageCode, ...translationData });
      await translation.save();
    }

    // Перевод живёт в своей таблице — помечаем сам рецепт изменённым, чтобы
    // новое название ушло в /app/sync.
    recipe.f.utime = new Date();
    await recipe.save();

    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return RecipeService.getFullById(recipeId, languageCode);
  }

  static async removeTranslation(recipeId, languageCode) {
    const translations = await RecipeTranslationModel.getByRecipeId(recipeId);
    if (translations.length <= 1) throw new Error('Cannot remove the last translation of a recipe');

    const translation = translations.find(t => t.f.language_code === languageCode);
    if (!translation) throw new Error('Translation not found');

    await translation.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return { success: true };
  }

  // Мягкое удаление (deleted_at), а не DELETE — строка остаётся как tombstone
  // для /app/sync (см. CatalogSyncService), иначе устройство с локальным
  // кэшем каталога никогда не узнает, что рецепт пропал. Переводы и связи
  // (состав, теги) не трогаем — они просто больше не всплывают нигде, т.к.
  // все чтения фильтруют deleted_at IS NULL.
  static async remove(id) {
    const recipe = await RecipeService.getById(id);
    recipe.f.deleted_at = new Date();
    await recipe.save();
    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return { success: true };
  }

  static async removeOwn(userId, id) {
    const recipe = await RecipeModel.getById(id);
    assertOwnPrivate(recipe, userId, 'Recipe');
    return RecipeService.remove(id);
  }

  // Админ добавляет пользовательский рецепт в общий каталог (тот же id).
  // Личные ингредиенты автора из состава публикуются вместе с ним — иначе
  // остальные пользователи получили бы рецепт со скрытыми ингредиентами.
  static async publish(id) {
    const recipe = await RecipeService.getById(id);
    const composition = await RecipeIngredientModel.getByRecipeId(id);
    const ingredients = await IngredientModel.getByIds(composition.map(row => row.f.ingredient_id));

    const publishedIngredientIds = [];
    for (const ingredient of ingredients) {
      if (ingredient.f.is_public) continue;
      ingredient.f.is_public = true;
      ingredient.f.published_at = new Date();
      await ingredient.save();
      publishedIngredientIds.push(ingredient.f.id);
    }
    if (publishedIngredientIds.length) await DictionaryUpdateModel.touch(DICTIONARIES.INGREDIENT);

    if (!recipe.f.is_public) {
      recipe.f.is_public = true;
      recipe.f.published_at = new Date();
      await recipe.save();
      await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    }

    return { ...(await RecipeService.getAdminDetail(id)), publishedIngredientIds };
  }
}
