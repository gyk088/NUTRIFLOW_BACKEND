import RecipeModel from '../models/RecipeModel.js';
import RecipeIngredientModel from '../models/RecipeIngredientModel.js';
import RecipeTagModel from '../models/RecipeTagModel.js';
import IngredientModel from '../models/IngredientModel.js';
import TagModel from '../models/TagModel.js';
import DictionaryUpdateModel from '../models/DictionaryUpdateModel.js';
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
    throw new Error(`No gram conversion for unit "${unit}" on ingredient "${ingredient.f.name}"`);
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
  static async create(data, ingredients = [], tagIds = []) {
    const recipe = new RecipeModel(data);
    await recipe.save();

    try {
      await saveComposition(recipe.f.id, ingredients, tagIds);
    } catch (error) {
      // Pool выдаёт по соединению на каждый query(), так что настоящей
      // SQL-транзакции здесь не выйдет — откатываем состав вручную.
      await RecipeIngredientModel.deleteByRecipeId(recipe.f.id);
      await RecipeTagModel.deleteByRecipeId(recipe.f.id);
      await recipe.delete();
      throw error;
    }

    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return RecipeService.getFullById(recipe.f.id);
  }

  static async getById(id) {
    const recipe = await RecipeModel.getById(id);
    if (!recipe) throw new Error('Recipe not found');
    return recipe;
  }

  static async getFullById(id) {
    const recipe = await RecipeService.getById(id);

    const composition = await RecipeIngredientModel.getByRecipeId(id);
    const ingredientIds = composition.map(row => row.f.ingredient_id);
    const ingredients = await IngredientModel.getByIds(ingredientIds);
    const ingredientsById = new Map(ingredients.map(ing => [ing.f.id, ing]));

    const recipeTags = await RecipeTagModel.getByRecipeId(id);
    const tags = await TagModel.getByIds(recipeTags.map(rt => rt.f.tag_id));

    const servings = recipe.f.servings || 1;
    const total = sumNutrition(composition, ingredientsById);
    const perServing = {};
    for (const field of NUTRIENT_FIELDS) {
      perServing[field] = round2(total[field] / servings);
      total[field] = round2(total[field]);
    }

    return {
      ...recipe.toJSON(),
      ingredients: composition.map(row => ({
        ingredient: ingredientsById.get(row.f.ingredient_id)?.toJSON(),
        quantity: row.f.quantity,
        unit: row.f.unit
      })),
      tags: tags.map(t => t.toJSON()),
      nutrition: { total, perServing }
    };
  }

  static async getAll(search) {
    return search ? RecipeModel.search(search) : RecipeModel.getAll();
  }

  static async update(id, updates, ingredients, tagIds) {
    const recipe = await RecipeService.getById(id);

    const allowed = ['name', 'description', 'image_url', 'servings'];
    for (const key of allowed) {
      if (updates[key] !== undefined) recipe.f[key] = updates[key];
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
    return RecipeService.getFullById(id);
  }

  static async remove(id) {
    const recipe = await RecipeService.getById(id);
    await RecipeIngredientModel.deleteByRecipeId(id);
    await RecipeTagModel.deleteByRecipeId(id);
    await recipe.delete();
    await DictionaryUpdateModel.touch(DICTIONARIES.RECIPE);
    return { success: true };
  }
}
