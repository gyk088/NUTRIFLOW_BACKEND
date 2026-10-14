import ExcelJS from 'exceljs';
import RecipeModel from '../models/RecipeModel.js';
import RecipeTranslationModel from '../models/RecipeTranslationModel.js';
import RecipeIngredientModel from '../models/RecipeIngredientModel.js';
import RecipeTagModel from '../models/RecipeTagModel.js';
import LanguageModel from '../models/LanguageModel.js';
import RecipeService from './RecipeService.js';
import { loadDefaultLangTagIndex } from '../utils/excelTagIndex.js';
import { loadDefaultLangIngredientIndex } from '../utils/excelIngredientIndex.js';

const SHEET_NAME = 'Recipes';

// Порядок и имена колонок — общие для экспорта и импорта: именно по этому
// заголовку (а не по позиции столбца) импорт понимает, что где лежит, так
// что колонки можно свободно переставлять местами в Excel.
function buildColumns(languages) {
  const columns = ['id'];
  for (const language of languages) {
    columns.push(`name_${language.f.code}`, `description_${language.f.code}`, `cook_time_${language.f.code}`, `steps_${language.f.code}`);
  }
  columns.push('image_url', 'servings', 'tags', 'ingredients');
  return columns;
}

// Состав рецепта в ячейке: "Название:количество:единица; Название2:кол-во:ед."
function formatComposition(rows, nameById) {
  return rows
    .map(row => {
      const name = nameById.get(row.f.ingredient_id);
      return name ? `${name}:${row.f.quantity}:${row.f.unit}` : null;
    })
    .filter(Boolean)
    .join('; ');
}

function parseComposition(value, idByName) {
  const text = String(value || '').trim();
  if (!text) return [];

  return text
    .split(';')
    .map(part => part.trim())
    .filter(Boolean)
    .map(part => {
      const [namePart, qtyPart, unitPart] = part.split(':').map(s => (s || '').trim());
      const ingredientId = idByName.get(namePart.toLowerCase());
      if (!ingredientId) throw new Error(`Ингредиент "${namePart}" не найден`);

      const quantity = Number(qtyPart);
      if (!quantity) throw new Error(`Некорректное количество для ингредиента "${namePart}"`);

      return { ingredient_id: ingredientId, quantity, unit: unitPart || 'g' };
    });
}

export default class RecipeExcelService {
  // Выгружает все (не удалённые) рецепты со всеми переводами, составом (по
  // названиям ингредиентов) и тегами в один .xlsx — одна строка на рецепт.
  static async export() {
    const languages = await LanguageModel.getAll();
    const defaultLangCode = languages.find(l => l.f.is_default)?.f.code || languages[0]?.f.code;

    const recipes = await RecipeModel.getAll();
    const ids = recipes.map(r => r.f.id);

    const [translations, composition, recipeTags, { labelById }, { nameById }] = await Promise.all([
      RecipeTranslationModel.getByRecipeIds(ids),
      RecipeIngredientModel.getByRecipeIds(ids),
      RecipeTagModel.getByRecipeIds(ids),
      loadDefaultLangTagIndex(defaultLangCode),
      loadDefaultLangIngredientIndex(defaultLangCode)
    ]);

    const translationsByRecipe = new Map();
    for (const t of translations) {
      const list = translationsByRecipe.get(t.f.recipe_id) || [];
      list.push(t);
      translationsByRecipe.set(t.f.recipe_id, list);
    }

    const compositionByRecipe = new Map();
    for (const row of composition) {
      const list = compositionByRecipe.get(row.f.recipe_id) || [];
      list.push(row);
      compositionByRecipe.set(row.f.recipe_id, list);
    }

    const tagIdsByRecipe = new Map();
    for (const rt of recipeTags) {
      const list = tagIdsByRecipe.get(rt.f.recipe_id) || [];
      list.push(rt.f.tag_id);
      tagIdsByRecipe.set(rt.f.recipe_id, list);
    }

    const columns = buildColumns(languages);
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet(SHEET_NAME);
    sheet.addRow(columns);
    sheet.getRow(1).font = { bold: true };

    for (const recipe of recipes) {
      const recipeTranslations = translationsByRecipe.get(recipe.f.id) || [];
      const translationByLang = new Map(recipeTranslations.map(t => [t.f.language_code, t]));
      const tagLabels = (tagIdsByRecipe.get(recipe.f.id) || []).map(tagId => labelById.get(tagId)).filter(Boolean);

      const row = { id: recipe.f.id };
      for (const language of languages) {
        const translation = translationByLang.get(language.f.code);
        row[`name_${language.f.code}`] = translation?.f.name || '';
        row[`description_${language.f.code}`] = translation?.f.description || '';
        row[`cook_time_${language.f.code}`] = translation?.f.cook_time || '';
        row[`steps_${language.f.code}`] = translation?.f.steps || '';
      }
      row.image_url = recipe.f.image_url || '';
      row.servings = recipe.f.servings || 1;
      row.tags = tagLabels.join(', ');
      row.ingredients = formatComposition(compositionByRecipe.get(recipe.f.id) || [], nameById);

      sheet.addRow(columns.map(key => row[key]));
    }

    for (const column of sheet.columns) column.width = 20;
    return workbook.xlsx.writeBuffer();
  }

  // Разбирает загруженный .xlsx: строка с `id`, совпадающим с существующим
  // рецептом, — обновляет его; строка без `id` (или с `id`, которого нет в
  // базе) — создаёт новый рецепт. Ингредиенты в колонке `ingredients`
  // ищутся по названию на языке по умолчанию (формат "Название:кол-во:ед.",
  // через "; " между позициями состава) — если название не найдено, строка
  // считается ошибочной. Колонки ищутся по заголовку, а не по позиции.
  static async import(buffer) {
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(buffer);
    const sheet = workbook.getWorksheet(SHEET_NAME) || workbook.worksheets[0];
    if (!sheet) throw new Error('В файле нет ни одного листа');

    const languages = await LanguageModel.getAll();
    const defaultLangCode = languages.find(l => l.f.is_default)?.f.code || languages[0]?.f.code;
    const [{ idByLabel }, { idByName }] = await Promise.all([
      loadDefaultLangTagIndex(defaultLangCode),
      loadDefaultLangIngredientIndex(defaultLangCode)
    ]);

    const headerRow = sheet.getRow(1);
    const headerByColumn = new Map();
    headerRow.eachCell((cell, colNumber) => {
      const header = String(cell.value || '').trim();
      if (header) headerByColumn.set(colNumber, header);
    });

    const results = { created: 0, updated: 0, errors: [] };

    for (let rowNumber = 2; rowNumber <= sheet.rowCount; rowNumber++) {
      const excelRow = sheet.getRow(rowNumber);
      if (excelRow.cellCount === 0) continue;

      const row = {};
      excelRow.eachCell((cell, colNumber) => {
        const header = headerByColumn.get(colNumber);
        if (header) row[header] = cell.value;
      });
      if (!Object.keys(row).length) continue;

      try {
        const action = await RecipeExcelService.importRow(row, languages, defaultLangCode, idByLabel, idByName);
        results[action]++;
      } catch (error) {
        results.errors.push({ row: rowNumber, error: error.message });
      }
    }

    return results;
  }

  static async importRow(row, languages, defaultLangCode, idByLabel, idByName) {
    const id = row.id ? String(row.id).trim() : null;

    const baseData = {
      image_url: row.image_url ? String(row.image_url).trim() : null,
      servings: row.servings ? Number(row.servings) || 1 : 1
    };

    const tagIds = String(row.tags || '')
      .split(',')
      .map(label => label.trim().toLowerCase())
      .filter(Boolean)
      .map(label => idByLabel.get(label))
      .filter(Boolean);

    const ingredients = parseComposition(row.ingredients, idByName);

    const translationsByLang = [];
    for (const language of languages) {
      const code = language.f.code;
      const name = row[`name_${code}`] ? String(row[`name_${code}`]).trim() : '';
      if (!name) continue;
      translationsByLang.push({
        code,
        name,
        description: row[`description_${code}`] ? String(row[`description_${code}`]).trim() : null,
        cook_time: row[`cook_time_${code}`] ? String(row[`cook_time_${code}`]).trim() : null,
        steps: row[`steps_${code}`] ? String(row[`steps_${code}`]).trim() : null
      });
    }

    const existing = id ? await RecipeModel.getById(id) : null;

    if (existing) {
      await RecipeService.update(id, baseData, ingredients, tagIds);
      for (const t of translationsByLang) {
        await RecipeService.addTranslation(id, t.code, { name: t.name, description: t.description, cook_time: t.cook_time, steps: t.steps });
      }
      return 'updated';
    }

    if (!translationsByLang.length) throw new Error('Нужно хотя бы одно название (name_<язык>) для нового рецепта');

    const first = translationsByLang.find(t => t.code === defaultLangCode) || translationsByLang[0];
    const created = await RecipeService.create(
      first.code,
      { name: first.name, description: first.description, cook_time: first.cook_time, steps: first.steps },
      baseData,
      ingredients,
      tagIds
    );

    for (const t of translationsByLang) {
      if (t.code === first.code) continue;
      await RecipeService.addTranslation(created.id, t.code, { name: t.name, description: t.description, cook_time: t.cook_time, steps: t.steps });
    }
    return 'created';
  }
}
