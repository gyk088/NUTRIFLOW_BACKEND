-- step 22: аватар пользователя хранится на бекенде (файл в /files/, см.
-- src/bll/utils/files.js), а не только локально на устройстве. Храним, как и
-- image_url у ingredient/recipe/article, только filename — базовый URL
-- настраивается на стороне клиентов.

BEGIN;

ALTER TABLE my_user ADD COLUMN photo_url character varying(255);

COMMENT ON COLUMN my_user.photo_url IS 'Filename аватара (в /files/), без базового URL — см. image_url у ingredient/recipe/article';

COMMIT;
