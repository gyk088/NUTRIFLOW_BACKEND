import { unlink } from 'fs/promises';
import path from 'path';
import LabReportModel from '../models/LabReportModel.js';
import LabResultModel from '../models/LabResultModel.js';
import GeminiService from './GeminiService.js';
import LanguageModel from '../models/LanguageModel.js';
import { saveUploadedFile, FILES_DIR } from '../utils/files.js';

const ALLOWED_MIME_TO_EXT = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'application/pdf': '.pdf'
};

// Gemini иногда возвращает нестрогий ISO ("2024-05-12T00:00:00") или мусор —
// сохраняем только валидную дату, иначе оставляем null (не гадаем).
function toDateOrNull(value) {
  if (!value) return null;
  const match = /^\d{4}-\d{2}-\d{2}/.exec(value);
  return match ? match[0] : null;
}

export default class LabReportService {
  // lang — код языка пояснений по показателям (см. /app/languages); без него или
  // для неизвестного кода берётся язык по умолчанию.
  static async create(userId, multipartFile, lang) {
    let saved;
    try {
      saved = await saveUploadedFile(multipartFile, ALLOWED_MIME_TO_EXT);
    } catch (error) {
      if (error.message.startsWith('Unsupported file type')) {
        throw new Error('Only JPEG, PNG, WEBP images or PDF files are allowed');
      }
      throw error;
    }

    const report = new LabReportModel({ user_id: userId, file_url: saved.url, status: 'processing' });
    await report.save();
    console.log(`Saved lab report ${report.f.id} for user ${userId}, file: ${saved.url}`);

    try {
      const language = (lang && (await LanguageModel.getByCode(lang))) || (await LanguageModel.getDefault());
      const parsed = await GeminiService.parseLabReport(saved.buffer, saved.mimetype, language?.f.name);

      report.f.lab_name = parsed.lab_name || null;
      report.f.taken_at = toDateOrNull(parsed.taken_at);
      report.f.raw_response = parsed;
      report.f.status = 'done';
      await report.save();

      for (const result of parsed.results || []) {
        const row = new LabResultModel({
          report_id: report.f.id,
          name: result.name,
          value: result.value,
          value_numeric: result.value_numeric ?? null,
          unit: result.unit || null,
          ref_range: result.ref_range || null,
          ref_min: result.ref_min ?? null,
          ref_max: result.ref_max ?? null,
          flag: result.flag || null,
          description: result.description || null,
          low_effects: result.low_effects || null,
          high_effects: result.high_effects || null,
          food_sources: JSON.stringify(Array.isArray(result.food_sources) ? result.food_sources : [])
        });
        await row.save();
      }
    } catch (error) {
      // Отчёт с оригиналом файла остаётся в базе даже при неудаче — чтобы не
      // заставлять пользователя перезагружать файл, если захотим когда-нибудь
      // добавить ручной повторный разбор.
      report.f.status = 'failed';
      report.f.error_message = error.message;
      await report.save();
    }

    return LabReportService.getFullById(report.f.id, userId);
  }

  static async getById(id) {
    const report = await LabReportModel.getById(id);
    if (!report) throw new Error('Lab report not found');
    return report;
  }

  // Не раскрываем чужие отчёты через 403 (это подтвердило бы существование
  // id) — для чужого/несуществующего отчёта одинаковый 404.
  static async getFullById(id, userId) {
    const report = await LabReportService.getById(id);
    if (report.f.user_id !== userId) throw new Error('Lab report not found');

    const results = await LabResultModel.getByReportId(id);
    return { ...report.toJSON(), results: results.map(r => r.toJSON()) };
  }

  static async getAll(userId) {
    return LabReportModel.getByUserId(userId);
  }

  static async remove(id, userId) {
    const report = await LabReportService.getById(id);
    if (report.f.user_id !== userId) throw new Error('Lab report not found');

    await LabResultModel.deleteByReportId(id);
    await report.delete();

    if (report.f.file_url) {
      const filename = path.basename(new URL(report.f.file_url).pathname);
      await unlink(path.join(FILES_DIR, filename)).catch(() => {});
    }
    return { success: true };
  }

  // История значений одного показателя по всем отчётам пользователя — для графика.
  static async getResultHistory(userId, name) {
    if (!name) throw new Error('name is required');
    return LabResultModel.getHistoryForUser(userId, name);
  }
}
