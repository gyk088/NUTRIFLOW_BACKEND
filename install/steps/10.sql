-- step 10: article — мультиязычность (ru/en), как у ingredient/recipe/tag
-- (см. install/steps/6.sql): отдельная колонка на язык, а не таблица переводов.

BEGIN;

ALTER TABLE article RENAME COLUMN title TO title_ru;
ALTER TABLE article ADD COLUMN title_en VARCHAR(200);
UPDATE article SET title_en = title_ru WHERE title_en IS NULL;
ALTER TABLE article ALTER COLUMN title_en SET NOT NULL;

ALTER TABLE article RENAME COLUMN content TO content_ru;
ALTER TABLE article ADD COLUMN content_en TEXT;

COMMENT ON COLUMN article.title_ru   IS 'Название на русском';
COMMENT ON COLUMN article.title_en   IS 'Название на английском';
COMMENT ON COLUMN article.content_ru IS 'HTML из rich-text редактора админки (Tiptap) на русском';
COMMENT ON COLUMN article.content_en IS 'HTML из rich-text редактора админки (Tiptap) на английском';

COMMIT;
