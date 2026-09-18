-- step 5: аллергены ингредиента — теперь связь с tag (type='allergen'),
-- а не свободный jsonb-массив строк

BEGIN;

ALTER TABLE ingredient DROP COLUMN allergens;

CREATE TABLE ingredient_tag (
    ingredient_id   uuid REFERENCES ingredient(id),
    tag_id          uuid REFERENCES tag(id),

    PRIMARY KEY (ingredient_id, tag_id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE ingredient_tag TO @@DBUSER@@;

COMMENT ON TABLE ingredient_tag IS 'Связь ингредиента с тегами (аллергены и т.п., по аналогии с recipe_tag)';

COMMIT;
