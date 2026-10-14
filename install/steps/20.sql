-- step 20: описание ингредиента — по языку, как у recipe.description
-- (install/steps/11.sql), а не в базовой таблице ingredient, т.к. это
-- переводимый текст.

BEGIN;

ALTER TABLE ingredient_translation ADD COLUMN description TEXT;

COMMENT ON COLUMN ingredient_translation.description IS 'Описание ингредиента на языке этого перевода';

COMMIT;
