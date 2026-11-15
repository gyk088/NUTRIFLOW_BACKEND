// Превью картинок для списков (по образцу ART_CRM).
//
// Оригиналы весят в среднем ~0.6 МБ (до 5 МБ), а в списках ингредиентов,
// рецептов и статей показываются маленькими карточками — без превью список
// из сотен записей тянет сотни мегабайт.
//
// Превью лежит рядом с оригиналами: files/thumbs/<имя без расширения>.webp
// (nginx отдаёт его той же location /files/). API по-прежнему отдаёт только
// filename оригинала, а клиенты строят адрес превью сами по этому правилу и
// при ошибке загрузки показывают оригинал. Создаётся при загрузке картинки
// (FileService.upload, UserService.uploadPhoto); для старых файлов — скрипт
// install/make-thumbs.mjs. Файлы анализов (lab_report) превью не получают.
//
// sharp подключается лениво: если пакет не установлен, бэкенд работает как
// раньше, просто без превью.
import fs from 'fs';
import path from 'path';
import { FILES_DIR } from './files.js';

export const THUMB_DIR = path.join(FILES_DIR, 'thumbs');
export const THUMB_SIZE = 480;

const IMAGE_EXTS = new Set(['jpg', 'jpeg', 'png', 'webp', 'gif', 'avif', 'tif', 'tiff']);

function split(filename) {
  const name = path.basename(String(filename || ''));
  const dot = name.lastIndexOf('.');
  if (dot <= 0) return null;
  return { name, base: name.slice(0, dot), ext: name.slice(dot + 1).toLowerCase() };
}

export const isThumbable = (filename) => {
  const parts = split(filename);
  return !!parts && IMAGE_EXTS.has(parts.ext);
};

// Имя превью относительно /files/ ("thumbs/<base>.webp") или null.
export function thumbName(filename) {
  const parts = split(filename);
  return parts && IMAGE_EXTS.has(parts.ext) ? `thumbs/${parts.base}.webp` : null;
}

export function thumbPath(filename) {
  const parts = split(filename);
  return parts ? path.join(THUMB_DIR, `${parts.base}.webp`) : null;
}

let sharpPromise = null;
function loadSharp() {
  if (!sharpPromise) {
    sharpPromise = import('sharp')
      .then((m) => {
        const sharp = m.default;
        sharp.concurrency(1); // не отнимаем все ядра у API
        sharp.cache(false);
        return sharp;
      })
      .catch((err) => {
        console.warn('[thumbs] sharp не установлен — превью не создаются:', err.message);
        return null;
      });
  }
  return sharpPromise;
}

/**
 * Создать превью для файла из files/. Ошибки не пробрасываются: превью —
 * оптимизация, из-за неё загрузка файла падать не должна.
 * @return {Promise<boolean>} создано ли (или уже есть) превью
 */
export async function makeThumb(filename, { force = false } = {}) {
  if (!isThumbable(filename)) return false;
  const sharp = await loadSharp();
  if (!sharp) return false;

  const { name } = split(filename);
  const target = thumbPath(filename);
  try {
    if (!force && fs.existsSync(target)) return true;
    await fs.promises.mkdir(THUMB_DIR, { recursive: true });
    const tmp = `${target}.${process.pid}.tmp`;
    await sharp(path.join(FILES_DIR, name), { failOn: 'none', limitInputPixels: 100_000_000 })
      .rotate() // учитываем EXIF-ориентацию фото с телефона
      .resize(THUMB_SIZE, THUMB_SIZE, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 78 })
      .toFile(tmp);
    await fs.promises.rename(tmp, target);
    return true;
  } catch (err) {
    console.warn(`[thumbs] не удалось создать превью ${name}:`, err.message);
    return false;
  }
}

export async function removeThumb(filename) {
  const target = thumbPath(filename);
  if (target) await fs.promises.unlink(target).catch(() => {});
}
