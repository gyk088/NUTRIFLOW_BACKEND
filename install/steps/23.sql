-- step 23: пользовательские ингредиенты и рецепты.
--
-- Пользователь мобильного приложения может создать свой ингредиент (чтобы
-- использовать его в своём рецепте) и свой рецепт. Они живут в тех же
-- таблицах ingredient/recipe, что и общий каталог, но с владельцем:
--   user_id IS NULL,     is_public = true  — создано в админке (общий каталог)
--   user_id = <автор>,   is_public = false — личное, видит только автор
--   user_id = <автор>,   is_public = true  — админ добавил в общий каталог
--                                            (тот же id, автор сохраняется)
-- Раньше собственные рецепты хранились JSON-ом в my_user.preferences.myRecipes —
-- там их не видно админке и нельзя сослаться на них из каталога.
--
-- ON DELETE SET NULL: при удалении аккаунта личные записи удаляет
-- UserService.deleteAccount, а уже опубликованные остаются в каталоге без автора.

BEGIN;

ALTER TABLE ingredient ADD COLUMN user_id      uuid REFERENCES my_user(id) ON DELETE SET NULL;
ALTER TABLE ingredient ADD COLUMN is_public    boolean NOT NULL DEFAULT true;
ALTER TABLE ingredient ADD COLUMN published_at timestamp(6) with time zone;

ALTER TABLE recipe ADD COLUMN user_id      uuid REFERENCES my_user(id) ON DELETE SET NULL;
ALTER TABLE recipe ADD COLUMN is_public    boolean NOT NULL DEFAULT true;
ALTER TABLE recipe ADD COLUMN published_at timestamp(6) with time zone;

CREATE INDEX ingredient_user_id_idx ON ingredient (user_id) WHERE user_id IS NOT NULL;
CREATE INDEX recipe_user_id_idx     ON recipe (user_id)     WHERE user_id IS NOT NULL;
CREATE INDEX recipe_ingredient_ingredient_id_idx ON recipe_ingredient (ingredient_id);

COMMENT ON COLUMN ingredient.user_id      IS 'Автор-пользователь приложения (NULL — создано в админке)';
COMMENT ON COLUMN ingredient.is_public    IS 'true — в общем каталоге, false — личный ингредиент автора (виден только ему)';
COMMENT ON COLUMN ingredient.published_at IS 'Когда пользовательский ингредиент добавлен админом в общий каталог';
COMMENT ON COLUMN recipe.user_id          IS 'Автор-пользователь приложения (NULL — создано в админке)';
COMMENT ON COLUMN recipe.is_public        IS 'true — в общем каталоге, false — личный рецепт автора (виден только ему)';
COMMENT ON COLUMN recipe.published_at     IS 'Когда пользовательский рецепт добавлен админом в общий каталог';

COMMIT;
