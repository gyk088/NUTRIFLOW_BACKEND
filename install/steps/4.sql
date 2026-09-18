-- step 4: recipe — время готовки и шаги приготовления

BEGIN;

ALTER TABLE recipe ADD COLUMN cook_time VARCHAR(100);
ALTER TABLE recipe ADD COLUMN steps     TEXT;

COMMENT ON COLUMN recipe.cook_time IS 'Время готовки в свободном формате (напр. "30 минут", "1 час 20 минут")';
COMMENT ON COLUMN recipe.steps     IS 'Шаги приготовления одним текстом (как description)';

COMMIT;
