-- step 6: мультиязычный контент (ru/en) для ingredient/recipe/tag.
-- Подход — отдельная колонка на язык (name_ru, name_en...), а не отдельная
-- таблица переводов: добавление нового языка в будущем — это новый шаг
-- миграции с колонками `<field>_<lang>`, без смены формы запросов/моделей.

BEGIN;

-- ingredient.name -> name_ru + name_en (оба обязательны)
ALTER TABLE ingredient RENAME COLUMN name TO name_ru;
ALTER TABLE ingredient ADD COLUMN name_en VARCHAR(100);
UPDATE ingredient SET name_en = name_ru WHERE name_en IS NULL;
ALTER TABLE ingredient ALTER COLUMN name_en SET NOT NULL;

COMMENT ON COLUMN ingredient.name_ru IS 'Название на русском';
COMMENT ON COLUMN ingredient.name_en IS 'Название на английском';

-- recipe.name -> name_ru + name_en (оба обязательны)
ALTER TABLE recipe RENAME COLUMN name TO name_ru;
ALTER TABLE recipe ADD COLUMN name_en VARCHAR(150);
UPDATE recipe SET name_en = name_ru WHERE name_en IS NULL;
ALTER TABLE recipe ALTER COLUMN name_en SET NOT NULL;

-- recipe.description/steps/cook_time -> по языку (необязательные, как и раньше)
ALTER TABLE recipe RENAME COLUMN description TO description_ru;
ALTER TABLE recipe ADD COLUMN description_en TEXT;

ALTER TABLE recipe RENAME COLUMN steps TO steps_ru;
ALTER TABLE recipe ADD COLUMN steps_en TEXT;

ALTER TABLE recipe RENAME COLUMN cook_time TO cook_time_ru;
ALTER TABLE recipe ADD COLUMN cook_time_en VARCHAR(100);

COMMENT ON COLUMN recipe.name_ru         IS 'Название на русском';
COMMENT ON COLUMN recipe.name_en         IS 'Название на английском';
COMMENT ON COLUMN recipe.description_ru  IS 'Описание на русском';
COMMENT ON COLUMN recipe.description_en  IS 'Описание на английском';
COMMENT ON COLUMN recipe.steps_ru        IS 'Шаги приготовления на русском';
COMMENT ON COLUMN recipe.steps_en        IS 'Шаги приготовления на английском';
COMMENT ON COLUMN recipe.cook_time_ru    IS 'Время готовки на русском (свободный текст)';
COMMENT ON COLUMN recipe.cook_time_en    IS 'Время готовки на английском (свободный текст)';

-- tag.name -> name_ru + name_en (оба обязательны). UNIQUE(type, name)
-- автоматически становится UNIQUE(type, name_ru) при переименовании колонки.
ALTER TABLE tag RENAME COLUMN name TO name_ru;
ALTER TABLE tag ADD COLUMN name_en VARCHAR(60);
UPDATE tag SET name_en = name_ru WHERE name_en IS NULL;
ALTER TABLE tag ALTER COLUMN name_en SET NOT NULL;

COMMENT ON COLUMN tag.name_ru IS 'Название на русском';
COMMENT ON COLUMN tag.name_en IS 'Название на английском';

COMMIT;
