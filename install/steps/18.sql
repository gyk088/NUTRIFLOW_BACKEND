-- step 18: soft delete (tombstones) для ingredient/recipe/tag.
--
-- Раньше DELETE физически стирал строку — мобильное приложение, кэширующее
-- каталог локально через /app/sync?since=, никогда не узнавало об удалении
-- (sync отдавал только "что изменилось", а не "что пропало"). Теперь удаление
-- ставит deleted_at, строка скрывается из всех обычных чтений (getAll/getById/
-- search/getUpdatedSince), но остаётся как tombstone — CatalogSyncService
-- дополнительно отдаёт deletedIds, собранные по deleted_at > since.

BEGIN;

ALTER TABLE ingredient ADD COLUMN deleted_at timestamp(6) with time zone;
ALTER TABLE recipe     ADD COLUMN deleted_at timestamp(6) with time zone;
ALTER TABLE tag        ADD COLUMN deleted_at timestamp(6) with time zone;

COMMENT ON COLUMN ingredient.deleted_at IS 'Мягкое удаление — если задано, строка скрыта из всех обычных чтений, но остаётся как tombstone для /app/sync (deletedIds)';
COMMENT ON COLUMN recipe.deleted_at     IS 'Мягкое удаление — см. ingredient.deleted_at';
COMMENT ON COLUMN tag.deleted_at        IS 'Мягкое удаление — см. ingredient.deleted_at';

COMMIT;
