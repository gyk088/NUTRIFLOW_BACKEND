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

// Сущность (тег/ингредиент/рецепт/статья) осталась без единого перевода —
// например, их удалили вручную в базе. Показать её нечем (нет названия), но
// это не должно ронять ни списки, ни синхронизацию.
export class MissingTranslationsError extends Error {}

// Резолвит список сущностей, молча пропуская те, у которых нет переводов.
export async function resolveAll(items, resolver) {
  const resolved = await Promise.all(items.map(item =>
    resolver(item).catch(error => {
      if (error instanceof MissingTranslationsError) return null;
      throw error;
    })
  ));
  return resolved.filter(Boolean);
}
