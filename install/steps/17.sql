-- step 17: ingredient.default_unit — в чём измеряется ингредиент по умолчанию
-- (штуки для яйца, мл для молока, граммы для крупы...). Нутриенты по-прежнему
-- заданы на 100 г / 100 мл; для нестандартных единиц (piece, tbsp...) вес в
-- граммах берётся из ingredient.grams_per_unit.

BEGIN;

ALTER TABLE ingredient ADD COLUMN default_unit VARCHAR(20) NOT NULL DEFAULT 'g';

COMMENT ON COLUMN ingredient.default_unit IS 'Единица измерения по умолчанию: g, kg, ml, l, piece, tbsp, tsp, cup, slice, clove. Подставляется при добавлении в рецепт; для не-весовых единиц нужна запись в grams_per_unit';

COMMIT;
