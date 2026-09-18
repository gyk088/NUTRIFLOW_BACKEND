import { randomUUID } from 'crypto';
import { writeFile, unlink } from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import { getFileBaseUrl } from '../utils/const.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const FILES_DIR = path.join(__dirname, '..', '..', '..', 'files');

const ALLOWED_MIME_TO_EXT = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'image/gif': '.gif'
};

export default class FileService {
  static async upload(multipartFile) {
    if (!multipartFile) throw new Error('No file was uploaded');

    const ext = ALLOWED_MIME_TO_EXT[multipartFile.mimetype];
    if (!ext) throw new Error('Only JPEG, PNG, WEBP or GIF images are allowed');

    // Случайное имя, а не оригинальное — не доверяем присланному имени файла
    // (обход пути, коллизии) и заодно исключаем угадывание чужих файлов по URL.
    const filename = `${randomUUID()}${ext}`;
    const buffer = await multipartFile.toBuffer();
    await writeFile(path.join(FILES_DIR, filename), buffer);

    return { url: `${getFileBaseUrl()}/${filename}`, filename };
  }

  static async remove(filename) {
    // basename() отрезает любые сегменты пути — filename приходит из URL,
    // никогда не доверяем ему как буквальному пути на диске.
    const safeName = path.basename(filename);
    await unlink(path.join(FILES_DIR, safeName)).catch(() => {});
    return { success: true };
  }
}
