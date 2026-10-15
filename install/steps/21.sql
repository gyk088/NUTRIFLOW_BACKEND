-- step 21: словарь текстов интерфейса мобильного приложения (кнопки, подписи —
-- не контент вроде рецептов/статей). Один ключ ("common.back", "recipes.addRecipe",
-- как в i18next) — одна строка на язык, без общей языконезависимой базовой
-- таблицы: в отличие от tag/recipe/..., у ключа интерфейса нет своих
-- нетранслируемых полей (картинки и т.п.), сам key и есть идентичность.
--
-- Клиент держит эти же ключи зашитыми в JSON при сборке как базовый набор —
-- этот словарь не заменяет его, а дополняет/переопределяет поверх, так что
-- отсутствие ключа здесь не ломает интерфейс (просто берётся из JSON).

BEGIN;

CREATE TABLE app_translation (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL PRIMARY KEY,
    language_code character varying(10) NOT NULL REFERENCES language(code),
    key character varying(255) NOT NULL,
    value text NOT NULL,
    ctime timestamp(6) with time zone DEFAULT now(),
    utime timestamp(6) with time zone,
    UNIQUE (language_code, key)
);

COMMENT ON TABLE app_translation IS 'Словарь текстов интерфейса мобильного приложения, по языку и ключу (как в i18next)';
COMMENT ON COLUMN app_translation.key IS 'Путь ключа как в i18next, напр. "common.back"';
COMMENT ON COLUMN app_translation.value IS 'Переведённый текст на языке language_code';

COMMIT;
