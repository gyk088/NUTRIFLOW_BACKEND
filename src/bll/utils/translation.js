// Выбор перевода под запрошенный язык с fallback на язык по умолчанию —
// общая логика для Article/Tag/Ingredient/Recipe (каждый теперь хранит
// переводы отдельными строками в своей *_translation таблице).
export function pickTranslation(translations, languageCode, defaultLanguageCode) {
  return (
    translations.find(t => t.f.language_code === languageCode) ||
    translations.find(t => t.f.language_code === defaultLanguageCode) ||
    translations[0]
  );
}
