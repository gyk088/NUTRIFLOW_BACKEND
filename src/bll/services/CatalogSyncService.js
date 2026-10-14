import IngredientModel from '../models/IngredientModel.js';
import RecipeModel from '../models/RecipeModel.js';
import TagModel from '../models/TagModel.js';
import IngredientService from './IngredientService.js';
import RecipeService from './RecipeService.js';
import TagService from './TagService.js';
import { resolveAll } from '../utils/translation.js';

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
      resolveAll(changedIngredients, ingredient => IngredientService.getFullById(ingredient.f.id, lang)),
      resolveAll(changedRecipes, recipe => RecipeService.getFullById(recipe.f.id, lang)),
      TagService.getManyResolved(changedTags.map(tag => tag.f.id), lang)
    ]);

    // Удаление в админке — это мягкое удаление (deleted_at), а не DELETE
    // (см. IngredientService/RecipeService/TagService.remove): строка остаётся
    // как tombstone, и вот здесь мы говорим клиенту убрать её id из локального
    // кэша — иначе устройство, закэшировавшее каталог, никогда не узнает об
    // удалении, ведь обычный GET/список просто перестал бы её упоминать.
    const [deletedIngredientIds, deletedRecipeIds, deletedTagIds] = await Promise.all([
      IngredientModel.getDeletedIdsSince(since),
      RecipeModel.getDeletedIdsSince(since),
      TagModel.getDeletedIdsSince(since)
    ]);

    return {
      recipes,
      ingredients,
      tags,
      deletedIds: { recipes: deletedRecipeIds, ingredients: deletedIngredientIds, tags: deletedTagIds },
      syncedAt
    };
  }
}
