// Разово создать превью (files/thumbs/<имя>.webp) для уже загруженных картинок.
// Запуск из папки бэкенда:  node install/make-thumbs.mjs   (--force — пересоздать все)
// Повторный запуск безопасен — существующие превью пропускаются.
//
// Берёт только картинки, на которые ссылается контент (ingredient/recipe/
// article.image_url, my_user.photo_url) — файлы анализов (lab_report) и
// неиспользуемые загрузки превью не получают.
import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import pg from 'pg';
import { FILES_DIR } from '../src/bll/utils/files.js';
import { isThumbable, makeThumb, thumbPath } from '../src/bll/utils/thumbs.js';

const force = process.argv.includes('--force');

const client = new pg.Client({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  port: process.env.DB_PORT,
});
await client.connect();
const { rows } = await client.query(`
  SELECT image_url AS f FROM ingredient WHERE image_url IS NOT NULL AND image_url <> ''
  UNION SELECT image_url FROM recipe  WHERE image_url IS NOT NULL AND image_url <> ''
  UNION SELECT image_url FROM article WHERE image_url IS NOT NULL AND image_url <> ''
  UNION SELECT photo_url FROM my_user WHERE photo_url IS NOT NULL AND photo_url <> ''
`);
await client.end();

const names = [...new Set(rows.map((r) => path.basename(r.f)))];
const missingOriginal = names.filter((name) => !fs.existsSync(path.join(FILES_DIR, name)));
const files = names
  .filter((name) => isThumbable(name) && fs.existsSync(path.join(FILES_DIR, name)))
  .filter((name) => force || !fs.existsSync(thumbPath(name)));

console.log(`Картинок в контенте: ${names.length}, без файла на диске: ${missingOriginal.length}, нужно превью: ${files.length}`);
let done = 0;
let failed = 0;
const started = Date.now();
for (const name of files) {
  if (await makeThumb(name, { force })) done++;
  else failed++;
  if ((done + failed) % 50 === 0) console.log(`  ${done + failed}/${files.length}`);
}
console.log(`Готово: создано ${done}, не удалось ${failed}, ${Math.round((Date.now() - started) / 1000)} с`);
