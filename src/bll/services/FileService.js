import { unlink } from 'fs/promises';
import path from 'path';
import { saveUploadedFile, FILES_DIR } from '../utils/files.js';

const ALLOWED_MIME_TO_EXT = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'image/gif': '.gif'
};

export default class FileService {
  static async upload(multipartFile) {
    try {
      const { url, filename } = await saveUploadedFile(multipartFile, ALLOWED_MIME_TO_EXT);
      return { url, filename };
    } catch (error) {
      if (error.message.startsWith('Unsupported file type')) {
        throw new Error('Only JPEG, PNG, WEBP or GIF images are allowed');
      }
      throw error;
    }
  }

  static async remove(filename) {
    // basename() отрезает любые сегменты пути — filename приходит из URL,
    // никогда не доверяем ему как буквальному пути на диске.
    const safeName = path.basename(filename);
    await unlink(path.join(FILES_DIR, safeName)).catch(() => {});
    return { success: true };
  }
}
