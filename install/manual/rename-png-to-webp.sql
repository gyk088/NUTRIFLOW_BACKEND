-- Переименовывает ссылки на изображения в БД с .png на .webp — после того как
-- сами файлы (в /files/) были пересжаты из PNG в WebP (~15x меньше размер,
-- без видимой потери качества — это фото, не графика с прозрачностью,
-- кроме нескольких RGBA-файлов, которые WebP тоже поддерживает).
-- Имя файла (UUID) не меняется, только расширение — так что это чисто
-- текстовая замена ссылок, без необходимости трогать сами строки где-то ещё.
-- Безопасно перезапускать повторно (WHERE ... LIKE '%.png' просто не найдёт
-- уже переименованные строки во второй раз).

BEGIN;

UPDATE ingredient SET image_url = regexp_replace(image_url, '\.png$', '.webp')
WHERE image_url LIKE '%.png';

UPDATE recipe SET image_url = regexp_replace(image_url, '\.png$', '.webp')
WHERE image_url LIKE '%.png';

UPDATE article SET image_url = regexp_replace(image_url, '\.png$', '.webp')
WHERE image_url LIKE '%.png';

UPDATE my_user SET photo_url = regexp_replace(photo_url, '\.png$', '.webp')
WHERE photo_url LIKE '%.png';

COMMIT;
