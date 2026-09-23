import RecipeModel from '../models/RecipeModel.js';
import RecipeTranslationModel from '../models/RecipeTranslationModel.js';
import RecipeIngredientModel from '../models/RecipeIngredientModel.js';
import RecipeTagModel from '../models/RecipeTagModel.js';
import IngredientModel from '../models/IngredientModel.js';
import IngredientTranslationModel from '../models/IngredientTranslationModel.js';
import TagService from './TagService.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
import LanguageService from './LanguageService.js';
import { pickTranslation } from '../utils/translation.js';
import { NUTRIENT_FIELDS } from '../utils/nutrients.js';
import { DICTIONARIES } from '../utils/const.js';

const UNIT_TO_GRAMS = { g: 1, kg: 1000, ml: 1, l: 1000 };

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

export default class RecipeService {
  // languageCode — язык первого перевода. translationData — {name, description, cook_time, steps}.
  static async create(languageCode, translationData, baseData, ingredients = [], tagIds = []) {
    const recipe = new RecipeModel(baseData);
    await recipe.save();

    try {
      const translation = new RecipeTranslationModel({ recipe_id: recipe.f.id, language_code: languageCode, ...translationData });
      await translation.save();
      await saveComposition(recipe.f.id, ingredients, tagIds);
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
    if (!recipe) throw new Error('Recipe not found');
    return recipe;
  }

  static async getFullById(id, lang) {
    const recipe = await RecipeService.getById(id);

    const translations = await RecipeTranslationModel.getByRecipeId(id);
    if (!translations.length) throw new Error('Recipe has no translations');
    const defaultLang = await LanguageService.getDefaultCode();
    const translation = pickTranslation(translations, lang, defaultLang);

    const composition = await RecipeIngredientModel.getByRecipeId(id);
    const ingredientIds = composition.map(row => row.f.ingredient_id);
    const ingredients = await IngredientModel.getByIds(ingredientIds);
    const ingredientsById = new Map(ingredients.map(ing => [ing.f.id, ing]));
    const ingredientNames = await resolveIngredientNames(ingredientIds, lang);

    const recipeTags = await RecipeTagModel.getByRecipeId(id);
    const tags = await TagService.getManyResolved(recipeTags.map(rt => rt.f.tag_id), lang);

    const servings = recipe.f.servings || 1;
    const total = sumNutrition(composition, ingredientsById);
    const perServing = {};
    for (const field of NUTRIENT_FIELDS) {
      perServing[field] = round2(total[field] / servings);
      total[field] = round2(total[field]);
    }

    return {
      ...recipe.toJSON(),
      name: translation.f.name,
      description: translation.f.description,
      cook_time: translation.f.cook_time,
      steps: translation.f.steps,
      language: translation.f.language_code,
      availableLanguages: translations.map(t => t.f.language_code),
      ingredients: composition.map(row => ({
        ingredient: { ...ingredientsById.get(row.f.ingredient_id)?.toJSON(), name: ingredientNames.get(row.f.ingredient_id) },
        quantity: row.f.quantity,
        unit: row.f.unit
      })),
      tags,
      nutrition: { total, perServing }
    };
  }

  // Для формы редактирования в админке — все переводы сразу.
  static async getAdminDetail(id) {
    const recipe = await RecipeService.getById(id);
    const translations = await RecipeTranslationModel.getByRecipeId(id);
    const composition = await RecipeIngredientModel.getByRecipeId(id);
    const recipeTags = await RecipeTagModel.getByRecipeId(id);

    const ingredientIds = composition.map(row => row.f.ingredient_id);
    const ingredients = await IngredientModel.getByIds(ingredientIds);
    const ingredientsById = new Map(ingredients.map(ing => [ing.f.id, ing]));

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
      ingredients: composition.map(row => ({ ingredient_id: row.f.ingredient_id, quantity: row.f.quantity, unit: row.f.unit })),
      tagIds: recipeTags.map(rt => rt.f.tag_id),
      nutrition: { total, perServing }
    };
  }

  static async getAll(search, lang) {
    let ids = null;
    if (search) ids = await RecipeTranslationModel.searchRecipeIds(search);

    const recipes = ids ? await RecipeModel.getByIds(ids) : await RecipeModel.getAll();
    return Promise.all(recipes.map(recipe => RecipeService.getFullById(recipe.f.id, lang)));
  }

  static async update(id, baseUpdates, ingredients, tagIds) {
    const recipe = await RecipeService.getById(id);

    const allowed = ['image_url', 'servings'];
    for (const key of allowed) {
      if (baseUpdates[key] !== undefined) recipe.f[key] = baseUpdates[key];
    }
    await recipe.save();

    if (ingredients) {
      await RecipeIngredientModel.deleteByRecipeId(id);
    }
    if (tagIds) {
      await RecipeTagModel.deleteByRecipeId(id);
    }
    await saveComposition(id, ingredients || [], tagIds || []);

    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return RecipeService.getFullById(id, null);
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

  static async remove(id) {
    const recipe = await RecipeService.getById(id);
    await RecipeTranslationModel.deleteByRecipeId(id);
    await RecipeIngredientModel.deleteByRecipeId(id);
    await RecipeTagModel.deleteByRecipeId(id);
    await recipe.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return { success: true };
  }
}
