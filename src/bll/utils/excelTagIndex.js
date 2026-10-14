import TagModel from '../models/TagModel.js';
import TagTranslationModel from '../models/TagTranslationModel.js';

// Общее для IngredientExcelService/RecipeExcelService: тег в ячейке пишем как
// "type:название" на языке по умолчанию — название само по себе может
// повторяться в разных типах тегов, да и так сразу видно, что это за тег.
// labelById — для экспорта (tagId -> "type:название"), idByLabel — для
// импорта (нижний регистр "type:название" -> tagId).
export async function loadDefaultLangTagIndex(defaultLangCode) {
  const tags = await TagModel.getAll();
  const translations = await TagTranslationModel.getByTagIds(tags.map(t => t.f.id));

  const nameByTag = new Map();
  for (const t of translations) {
    if (t.f.language_code === defaultLangCode) nameByTag.set(t.f.tag_id, t.f.name);
  }

  const labelById = new Map();
  const idByLabel = new Map();
  for (const tag of tags) {
    const name = nameByTag.get(tag.f.id);
    if (!name) continue; // тег без перевода на язык по умолчанию — показать нечем, пропускаем
    const label = `${tag.f.type}:${name}`;
    labelById.set(tag.f.id, label);
    idByLabel.set(label.toLowerCase(), tag.f.id);
  }
  return { labelById, idByLabel };
}
