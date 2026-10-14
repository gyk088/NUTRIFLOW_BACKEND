import IngredientModel from '../models/IngredientModel.js';
import IngredientTranslationModel from '../models/IngredientTranslationModel.js';

// Для RecipeExcelService: состав рецепта в ячейке ссылается на ингредиент по
// названию на языке по умолчанию (а не по id — в Excel это неудобно читать и
// заполнять руками). nameById — для экспорта, idByName (нижний регистр) —
// для импорта. При совпадении названий у нескольких ингредиентов (редкий
// случай) побеждает первый — это ограничение подхода "искать по имени".
export async function loadDefaultLangIngredientIndex(defaultLangCode) {
  const ingredients = await IngredientModel.getAll();
  const translations = await IngredientTranslationModel.getByIngredientIds(ingredients.map(i => i.f.id));

  const nameByIngredient = new Map();
  for (const t of translations) {
    if (t.f.language_code === defaultLangCode) nameByIngredient.set(t.f.ingredient_id, t.f.name);
  }

  const nameById = new Map();
  const idByName = new Map();
  for (const ingredient of ingredients) {
    const name = nameByIngredient.get(ingredient.f.id);
    if (!name) continue; // ингредиент без перевода на язык по умолчанию — показать нечем, пропускаем
    nameById.set(ingredient.f.id, name);
    if (!idByName.has(name.toLowerCase())) idByName.set(name.toLowerCase(), ingredient.f.id);
  }
  return { nameById, idByName };
}
