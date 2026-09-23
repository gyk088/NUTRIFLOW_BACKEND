import IngredientModel from '../models/IngredientModel.js';
import RecipeModel from '../models/RecipeModel.js';
import TagModel from '../models/TagModel.js';
import IngredientService from './IngredientService.js';
import RecipeService from './RecipeService.js';
import TagService from './TagService.js';

export default class CatalogSyncService {
  // `since` — ISO-дата последней синхронизации на клиенте, либо null/undefined
  // при самой первой синхронизации (тогда отдаём весь текущий каталог).
  // `lang` — язык, на который резолвятся названия/тексты (с fallback на язык
  // по умолчанию, если для конкретной строки перевода ещё нет).
  // syncedAt в ответе — время СЕРВЕРА на момент этого запроса; клиент должен
  // сохранить именно его как новую точку отсчёта для следующего запроса
  // (а не, например, максимальный utime среди полученных строк).
  static async sync(since, lang) {
    const syncedAt = new Date();

    const [changedIngredients, changedRecipes, changedTags] = await Promise.all([
      IngredientModel.getUpdatedSince(since),
      RecipeModel.getUpdatedSince(since),
      TagModel.getUpdatedSince(since)
    ]);

    const [ingredients, recipes, tags] = await Promise.all([
      Promise.all(changedIngredients.map(ingredient => IngredientService.getFullById(ingredient.f.id, lang))),
      Promise.all(changedRecipes.map(recipe => RecipeService.getFullById(recipe.f.id, lang))),
      TagService.getManyResolved(changedTags.map(tag => tag.f.id), lang)
    ]);

    return { recipes, ingredients, tags, syncedAt };
  }
}
