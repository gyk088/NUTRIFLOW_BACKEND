-- step 11: полная переделка языковой модели.
--
-- Было: фиксированные колонки name_ru/name_en (и т.п.) — добавить новый язык
-- значило менять схему и код. Стало: список языков — данные (таблица
-- language, управляется из админки), а перевод каждой переводимой сущности —
-- ОТДЕЛЬНАЯ строка со своим id в *_translation таблице (article_translation,
-- tag_translation, ingredient_translation, recipe_translation), привязанная
-- к базовой записи по <entity>_id. Базовая запись хранит только то, что не
-- зависит от языка (картинка, состав рецепта, нутриенты, связи с тегами и
-- избранным) — она не дублируется на каждый язык.
--
-- Существующие RU/EN данные переносятся как есть, ничего не теряется.

BEGIN;

CREATE TABLE language (
    code        VARCHAR(10) NOT NULL,
    name        VARCHAR(60) NOT NULL,
    is_default  boolean NOT NULL DEFAULT false,
    ctime       timestamp(6) with time zone DEFAULT NOW(),

    PRIMARY KEY (code)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE language TO @@DBUSER@@;

COMMENT ON TABLE  language            IS 'Языки контента (управляется из админки, раздел "Языки") — заменяет фиксированные *_ru/*_en колонки';
COMMENT ON COLUMN language.code       IS 'Короткий код языка, напр. ru, en, pl, fr';
COMMENT ON COLUMN language.is_default IS 'Язык по умолчанию — используется как fallback, когда для сущности нет перевода на запрошенный язык. Ровно один язык должен быть default (следит сервисный слой)';

INSERT INTO language (code, name, is_default) VALUES
    ('ru', 'Русский', true),
    ('en', 'English', false);

-- ==================== article ====================

CREATE TABLE article_translation (
    id          uuid DEFAULT uuid_generate_v4(),
    article_id  uuid NOT NULL REFERENCES article(id),
    language_code VARCHAR(10) NOT NULL REFERENCES language(code),
    title       VARCHAR(200) NOT NULL,
    content     TEXT,

    UNIQUE (article_id, language_code),
    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE article_translation TO @@DBUSER@@;
COMMENT ON TABLE article_translation IS 'Перевод статьи на конкретный язык';

INSERT INTO article_translation (article_id, language_code, title, content)
SELECT id, 'ru', title_ru, content_ru FROM article;
INSERT INTO article_translation (article_id, language_code, title, content)
SELECT id, 'en', title_en, content_en FROM article;

ALTER TABLE article DROP COLUMN title_ru;
ALTER TABLE article DROP COLUMN title_en;
ALTER TABLE article DROP COLUMN content_ru;
ALTER TABLE article DROP COLUMN content_en;

-- ==================== tag ====================

CREATE TABLE tag_translation (
    id      uuid DEFAULT uuid_generate_v4(),
    tag_id  uuid NOT NULL REFERENCES tag(id),
    language_code VARCHAR(10) NOT NULL REFERENCES language(code),
    name    VARCHAR(60) NOT NULL,

    UNIQUE (tag_id, language_code),
    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE tag_translation TO @@DBUSER@@;
COMMENT ON TABLE tag_translation IS 'Перевод тега на конкретный язык';

INSERT INTO tag_translation (tag_id, language_code, name)
SELECT id, 'ru', name_ru FROM tag;
INSERT INTO tag_translation (tag_id, language_code, name)
SELECT id, 'en', name_en FROM tag;

ALTER TABLE tag DROP COLUMN name_ru;
ALTER TABLE tag DROP COLUMN name_en;

-- ==================== ingredient ====================

CREATE TABLE ingredient_translation (
    id            uuid DEFAULT uuid_generate_v4(),
    ingredient_id uuid NOT NULL REFERENCES ingredient(id),
    language_code VARCHAR(10) NOT NULL REFERENCES language(code),
    name          VARCHAR(100) NOT NULL,

    UNIQUE (ingredient_id, language_code),
    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ingredient_translation TO @@DBUSER@@;
COMMENT ON TABLE ingredient_translation IS 'Перевод ингредиента на конкретный язык';

INSERT INTO ingredient_translation (ingredient_id, language_code, name)
SELECT id, 'ru', name_ru FROM ingredient;
INSERT INTO ingredient_translation (ingredient_id, language_code, name)
SELECT id, 'en', name_en FROM ingredient;

ALTER TABLE ingredient DROP COLUMN name_ru;
ALTER TABLE ingredient DROP COLUMN name_en;

-- ==================== recipe ====================

CREATE TABLE recipe_translation (
    id          uuid DEFAULT uuid_generate_v4(),
    recipe_id   uuid NOT NULL REFERENCES recipe(id),
    language_code VARCHAR(10) NOT NULL REFERENCES language(code),
    name        VARCHAR(150) NOT NULL,
    description TEXT,
    cook_time   VARCHAR(100),
    steps       TEXT,

    UNIQUE (recipe_id, language_code),
    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE recipe_translation TO @@DBUSER@@;
COMMENT ON TABLE recipe_translation IS 'Перевод рецепта на конкретный язык';

INSERT INTO recipe_translation (recipe_id, language_code, name, description, cook_time, steps)
SELECT id, 'ru', name_ru, description_ru, cook_time_ru, steps_ru FROM recipe;
INSERT INTO recipe_translation (recipe_id, language_code, name, description, cook_time, steps)
SELECT id, 'en', name_en, description_en, cook_time_en, steps_en FROM recipe;

ALTER TABLE recipe DROP COLUMN name_ru;
ALTER TABLE recipe DROP COLUMN name_en;
ALTER TABLE recipe DROP COLUMN description_ru;
ALTER TABLE recipe DROP COLUMN description_en;
ALTER TABLE recipe DROP COLUMN cook_time_ru;
ALTER TABLE recipe DROP COLUMN cook_time_en;
ALTER TABLE recipe DROP COLUMN steps_ru;
ALTER TABLE recipe DROP COLUMN steps_en;

COMMIT;
