-- step 2: ingredient — базовая сущность продукта (морковь, свинина, оливковое масло...)
-- содержит полный нутриентный профиль на 100 г / 100 мл продукта
-- + recipe / recipe_ingredient — рецепт блюда и его состав

BEGIN;

CREATE TABLE ingredient (
    id              uuid DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL,
    image_url       VARCHAR(500),
    grams_per_unit  jsonb DEFAULT '{}'::jsonb,
    allergens       jsonb DEFAULT '[]'::jsonb,

    -- макронутриенты
    calories        NUMERIC(10,3) NOT NULL DEFAULT 0,
    protein         NUMERIC(10,3) NOT NULL DEFAULT 0,
    carbs           NUMERIC(10,3) NOT NULL DEFAULT 0,
    fat             NUMERIC(10,3) NOT NULL DEFAULT 0,
    fiber           NUMERIC(10,3) NOT NULL DEFAULT 0,
    sugar           NUMERIC(10,3) NOT NULL DEFAULT 0,
    saturated_fat   NUMERIC(10,3) NOT NULL DEFAULT 0,
    cholesterol     NUMERIC(10,3) NOT NULL DEFAULT 0,
    sodium          NUMERIC(10,3) NOT NULL DEFAULT 0,
    omega_3         NUMERIC(10,3) NOT NULL DEFAULT 0,
    omega_6         NUMERIC(10,3) NOT NULL DEFAULT 0,

    -- витамины
    vitamin_a       NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_b1      NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_b2      NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_b3      NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_b5      NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_b6      NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_b7      NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_b9      NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_b12     NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_c       NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_d       NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_e       NUMERIC(10,3) NOT NULL DEFAULT 0,
    vitamin_k       NUMERIC(10,3) NOT NULL DEFAULT 0,

    -- минералы
    calcium         NUMERIC(10,3) NOT NULL DEFAULT 0,
    iron            NUMERIC(10,3) NOT NULL DEFAULT 0,
    magnesium       NUMERIC(10,3) NOT NULL DEFAULT 0,
    phosphorus      NUMERIC(10,3) NOT NULL DEFAULT 0,
    potassium       NUMERIC(10,3) NOT NULL DEFAULT 0,
    zinc            NUMERIC(10,3) NOT NULL DEFAULT 0,
    copper          NUMERIC(10,3) NOT NULL DEFAULT 0,
    manganese       NUMERIC(10,3) NOT NULL DEFAULT 0,
    selenium        NUMERIC(10,3) NOT NULL DEFAULT 0,
    iodine          NUMERIC(10,3) NOT NULL DEFAULT 0,

    ctime           timestamp(6) with time zone DEFAULT NOW(),
    utime           timestamp(6) with time zone,

    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ingredient TO @@DBUSER@@;

COMMENT ON TABLE  ingredient                IS 'Ингредиент (продукт) — базовая сущность приложения. Все нутриенты указаны на 100 г / 100 мл продукта';
COMMENT ON COLUMN ingredient.grams_per_unit IS 'jsonb: вес в граммах для штучных/объёмных единиц измерения, напр. {"piece": 150, "tbsp": 13.5}';
COMMENT ON COLUMN ingredient.allergens      IS 'jsonb-массив аллергенов, напр. ["gluten", "dairy"]';
COMMENT ON COLUMN ingredient.calories       IS 'ккал на 100 г/мл';
COMMENT ON COLUMN ingredient.ctime          IS 'Дата создания';
COMMENT ON COLUMN ingredient.utime          IS 'Дата обновления';

CREATE TABLE recipe (
    id           uuid DEFAULT uuid_generate_v4(),
    name         VARCHAR(150) NOT NULL,
    description  TEXT,
    image_url    VARCHAR(500),
    servings     SMALLINT NOT NULL DEFAULT 1,
    ctime        timestamp(6) with time zone DEFAULT NOW(),
    utime        timestamp(6) with time zone,

    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE recipe TO @@DBUSER@@;

COMMENT ON TABLE  recipe           IS 'Рецепт блюда';
COMMENT ON COLUMN recipe.servings  IS 'На сколько порций рассчитан рецепт';
COMMENT ON COLUMN recipe.ctime     IS 'Дата создания';
COMMENT ON COLUMN recipe.utime     IS 'Дата обновления';

CREATE TABLE recipe_ingredient (
    recipe_id       uuid REFERENCES recipe(id),
    ingredient_id   uuid REFERENCES ingredient(id),
    quantity        NUMERIC(10,3) NOT NULL,
    unit            VARCHAR(20) NOT NULL DEFAULT 'g',

    PRIMARY KEY (recipe_id, ingredient_id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE recipe_ingredient TO @@DBUSER@@;

COMMENT ON TABLE  recipe_ingredient          IS 'Состав рецепта: какие ингредиенты и в каком количестве входят в одну порцию блюда';
COMMENT ON COLUMN recipe_ingredient.quantity IS 'Количество ингредиента на одну порцию в единицах, указанных в unit';
COMMENT ON COLUMN recipe_ingredient.unit     IS 'Единица измерения: g, kg, ml, l, piece, tbsp, tsp, cup, slice, clove и т.д. Для не-весовых единиц перевод в граммы — через ingredient.grams_per_unit';

CREATE TABLE tag (
    id      uuid DEFAULT uuid_generate_v4(),
    type    VARCHAR(30) NOT NULL,
    name    VARCHAR(60) NOT NULL,

    UNIQUE(type, name),
    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE tag TO @@DBUSER@@;

COMMENT ON TABLE  tag      IS 'Тег для рецепта. type задаёт группу тега (category, meal_type, dietary, allergen и т.д.), name — значение (breakfast, vegetarian, gluten...)';
COMMENT ON COLUMN tag.type IS 'Тип тега, напр. category, meal_type, dietary, allergen';
COMMENT ON COLUMN tag.name IS 'Значение тега внутри своего типа';

CREATE TABLE recipe_tag (
    recipe_id   uuid REFERENCES recipe(id),
    tag_id      uuid REFERENCES tag(id),

    PRIMARY KEY (recipe_id, tag_id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE recipe_tag TO @@DBUSER@@;

COMMENT ON TABLE recipe_tag IS 'Связь рецепта с тегами (категория, тип приёма пищи, диетические пометки, аллергены...)';

COMMIT;
