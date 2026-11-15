import { unlink } from 'fs/promises';
import path from 'path';
import { saveUploadedFile, FILES_DIR } from '../utils/files.js';
import { makeThumb, removeThumb, thumbName } from '../utils/thumbs.js';

const ALLOWED_MIME_TO_EXT = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'image/gif': '.gif'
};

export default class FileService {
  static async upload(multipartFile) {
    try {
      const { filename } = await saveUploadedFile(multipartFile, ALLOWED_MIME_TO_EXT);
      // превью для списков (files/thumbs/<имя>.webp), см. utils/thumbs.js
      const hasThumb = await makeThumb(filename);
      return { filename, thumb: hasThumb ? thumbName(filename) : null };
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
    await removeThumb(safeName);
    return { success: true };
  }
}
