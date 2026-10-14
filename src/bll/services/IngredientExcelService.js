import ExcelJS from 'exceljs';
import IngredientModel from '../models/IngredientModel.js';
import IngredientTranslationModel from '../models/IngredientTranslationModel.js';
import IngredientTagModel from '../models/IngredientTagModel.js';
import LanguageModel from '../models/LanguageModel.js';
import IngredientService from './IngredientService.js';
import { NUTRIENT_FIELDS } from '../utils/nutrients.js';
import { loadDefaultLangTagIndex } from '../utils/excelTagIndex.js';

const SHEET_NAME = 'Ingredients';

// Порядок и имена колонок — общие для экспорта и импорта: именно по этому
// заголовку (а не по позиции столбца) импорт понимает, что где лежит, так
// что колонки можно свободно переставлять местами в Excel.
function buildColumns(languages) {
  const columns = ['id'];
  for (const language of languages) {
    columns.push(`name_${language.f.code}`);
    columns.push(`description_${language.f.code}`);
  }
  columns.push('image_url', 'default_unit', 'grams_per_unit', 'tags');
  columns.push(...NUTRIENT_FIELDS);
  return columns;
}

export default class IngredientExcelService {
  // Выгружает все (не удалённые) ингредиенты со всеми переводами, базовыми
  // полями, нутриентами и тегами в один .xlsx — одна строка на ингредиент.
  static async export() {
    const languages = await LanguageModel.getAll();
    const defaultLangCode = languages.find(l => l.f.is_default)?.f.code || languages[0]?.f.code;

    const ingredients = await IngredientModel.getAll();
    const ids = ingredients.map(i => i.f.id);

    const [translations, ingredientTags, { labelById }] = await Promise.all([
      IngredientTranslationModel.getByIngredientIds(ids),
      IngredientTagModel.getByIngredientIds(ids),
      loadDefaultLangTagIndex(defaultLangCode)
    ]);

    const translationsByIngredient = new Map();
    for (const t of translations) {
      const list = translationsByIngredient.get(t.f.ingredient_id) || [];
      list.push(t);
      translationsByIngredient.set(t.f.ingredient_id, list);
    }

    const tagIdsByIngredient = new Map();
    for (const it of ingredientTags) {
      const list = tagIdsByIngredient.get(it.f.ingredient_id) || [];
      list.push(it.f.tag_id);
      tagIdsByIngredient.set(it.f.ingredient_id, list);
    }

    const columns = buildColumns(languages);
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet(SHEET_NAME);
    sheet.addRow(columns);
    sheet.getRow(1).font = { bold: true };

    for (const ingredient of ingredients) {
      const ingredientTranslations = translationsByIngredient.get(ingredient.f.id) || [];
      const translationByLang = new Map(ingredientTranslations.map(t => [t.f.language_code, t]));
      const tagLabels = (tagIdsByIngredient.get(ingredient.f.id) || [])
        .map(tagId => labelById.get(tagId))
        .filter(Boolean);

      const row = { id: ingredient.f.id };
      for (const language of languages) {
        const translation = translationByLang.get(language.f.code);
        row[`name_${language.f.code}`] = translation?.f.name || '';
        row[`description_${language.f.code}`] = translation?.f.description || '';
      }
      row.image_url = ingredient.f.image_url || '';
      row.default_unit = ingredient.f.default_unit || 'g';
      row.grams_per_unit = JSON.stringify(ingredient.f.grams_per_unit || {});
      row.tags = tagLabels.join(', ');
      for (const field of NUTRIENT_FIELDS) row[field] = Number(ingredient.f[field] || 0);

      sheet.addRow(columns.map(key => row[key]));
    }

    for (const column of sheet.columns) column.width = 20;
    return workbook.xlsx.writeBuffer();
  }

  // Разбирает загруженный .xlsx: строка с `id`, совпадающим с существующим
  // ингредиентом, — обновляет его; строка без `id` (или с `id`, которого нет
  // в базе) — создаёт новый ингредиент. Названия языков в заголовке
  // (name_<code>/description_<code>) должны совпадать с кодами из таблицы
  // language — незнакомые языки в файле просто игнорируются.
  static async import(buffer) {
    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(buffer);
    const sheet = workbook.getWorksheet(SHEET_NAME) || workbook.worksheets[0];
    if (!sheet) throw new Error('В файле нет ни одного листа');

    const languages = await LanguageModel.getAll();
    const defaultLangCode = languages.find(l => l.f.is_default)?.f.code || languages[0]?.f.code;
    const { idByLabel } = await loadDefaultLangTagIndex(defaultLangCode);
    const idByName = await loadIngredientIdByName();

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
        const action = await IngredientExcelService.importRow(row, languages, defaultLangCode, idByLabel, idByName);
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
      default_unit: row.default_unit ? String(row.default_unit).trim() : 'g',
      grams_per_unit: parseGramsPerUnit(row.grams_per_unit)
    };
    for (const field of NUTRIENT_FIELDS) {
      baseData[field] = row[field] !== undefined && row[field] !== '' ? Number(row[field]) || 0 : 0;
    }

    const tagIds = String(row.tags || '')
      .split(',')
      .map(label => label.trim().toLowerCase())
      .filter(Boolean)
      .map(label => idByLabel.get(label))
      .filter(Boolean);

    const translationsByLang = [];
    for (const language of languages) {
      const code = language.f.code;
      const name = row[`name_${code}`] ? String(row[`name_${code}`]).trim() : '';
      if (!name) continue;
      translationsByLang.push({ code, name, description: row[`description_${code}`] ? String(row[`description_${code}`]).trim() : null });
    }

    let targetId = id && (await IngredientModel.getById(id)) ? id : null;
    if (!targetId) {
      targetId = translationsByLang.map(t => idByName.get(nameKey(t.name))).find(Boolean) || null;
    }

    if (targetId) {
      await IngredientService.update(targetId, baseData, tagIds);
      for (const t of translationsByLang) {
        await IngredientService.addTranslation(targetId, t.code, t.name, t.description);
      }
      return 'updated';
    }

    if (!translationsByLang.length) throw new Error('Нужно хотя бы одно название (name_<язык>) для нового ингредиента');

    const first = translationsByLang.find(t => t.code === defaultLangCode) || translationsByLang[0];
    const created = await IngredientService.create(first.code, first.name, baseData, tagIds, first.description);

    for (const t of translationsByLang) {
      if (t.code !== first.code) await IngredientService.addTranslation(created.id, t.code, t.name, t.description);
      idByName.set(nameKey(t.name), created.id);
    }
    return 'created';
  }
}

function nameKey(name) {
  return name.trim().toLowerCase();
}

async function loadIngredientIdByName() {
  const ingredients = await IngredientModel.getAll();
  const translations = await IngredientTranslationModel.getByIngredientIds(ingredients.map(i => i.f.id));

  const idByName = new Map();
  for (const t of translations) {
    const key = nameKey(t.f.name);
    if (!idByName.has(key)) idByName.set(key, t.f.ingredient_id);
  }
  return idByName;
}

function parseGramsPerUnit(value) {
  if (!value) return {};
  try {
    const parsed = JSON.parse(String(value));
    return typeof parsed === 'object' && parsed ? parsed : {};
  } catch {
    return {};
  }
}
