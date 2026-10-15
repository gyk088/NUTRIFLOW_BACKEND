import { randomUUID } from 'crypto';
import { writeFile } from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const FILES_DIR = path.join(__dirname, '..', '..', '..', 'files');

// Общая логика сохранения загруженного multipart-файла на диск — используется
// FileService (картинки для контента) и LabReportService (фото/PDF анализов),
// у каждого свой allowedMimeToExt.
//
// Отдаём только filename, не полный URL — базовый URL раздачи файлов (/files/)
// настраивается на стороне клиентов (моб. приложение, админка), а не здесь.
export async function saveUploadedFile(multipartFile, allowedMimeToExt) {
  if (!multipartFile) throw new Error('No file was uploaded');

  const ext = allowedMimeToExt[multipartFile.mimetype];
  if (!ext) throw new Error(`Unsupported file type: ${multipartFile.mimetype}`);

  // Случайное имя, а не оригинальное — не доверяем присланному имени файла
  // (обход пути, коллизии) и заодно исключаем угадывание чужих файлов по имени.
  const filename = `${randomUUID()}${ext}`;
  const buffer = await multipartFile.toBuffer();
  await writeFile(path.join(FILES_DIR, filename), buffer);

  return { filename, buffer, mimetype: multipartFile.mimetype };
}
