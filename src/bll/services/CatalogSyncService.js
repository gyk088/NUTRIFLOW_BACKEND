import IngredientModel from '../models/IngredientModel.js';
import RecipeModel from '../models/RecipeModel.js';
import TagModel from '../models/TagModel.js';
import IngredientService from './IngredientService.js';
import RecipeService from './RecipeService.js';

export default class CatalogSyncService {
  // `since` — ISO-дата последней синхронизации на клиенте, либо null/undefined
  // при самой первой синхронизации (тогда отдаём весь текущий каталог).
  // syncedAt в ответе — время СЕРВЕРА на момент этого запроса; клиент должен
  // сохранить именно его как новую точку отсчёта для следующего запроса
  // (а не, например, максимальный utime среди полученных строк).
  static async sync(since) {
    const syncedAt = new Date();

    const [changedIngredients, changedRecipes, changedTags] = await Promise.all([
      IngredientModel.getUpdatedSince(since),
      RecipeModel.getUpdatedSince(since),
      TagModel.getUpdatedSince(since)
    ]);

    const [ingredients, recipes] = await Promise.all([
      Promise.all(changedIngredients.map(ingredient => IngredientService.getFullById(ingredient.f.id))),
      Promise.all(changedRecipes.map(recipe => RecipeService.getFullById(recipe.f.id)))
    ]);
    const tags = changedTags.map(tag => tag.toJSON());

    return { recipes, ingredients, tags, syncedAt };
  }
}
