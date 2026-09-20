-- step 7: tag.ctime/utime — нужны для инкрементальной синхронизации каталога
-- с мобильным приложением (см. GET /api/v1/app/sync?since=...): без даты
-- изменения нельзя определить, какие теги обновились с прошлой синхронизации.

BEGIN;

ALTER TABLE tag ADD COLUMN ctime timestamp(6) with time zone DEFAULT NOW();
ALTER TABLE tag ADD COLUMN utime timestamp(6) with time zone;

UPDATE tag SET ctime = NOW() WHERE ctime IS NULL;

COMMENT ON COLUMN tag.ctime IS 'Дата создания';
COMMENT ON COLUMN tag.utime IS 'Дата обновления';

COMMIT;
