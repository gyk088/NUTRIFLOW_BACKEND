import AppTranslationService from '../bll/services/AppTranslationService.js';

export default class AppTranslationController {
  // Публично — мобильное приложение грузит интерфейсные строки до входа.
  static async getDictionary(request, reply) {
    try {
      const dictionary = await AppTranslationService.getDictionary(request.query.lang);
      return dictionary;
    } catch (error) {
      reply.code(400).send({ error: error.message });
    }
  }

  static async getAdminDictionary(request, reply) {
    try {
      const { lang } = request.params;
      const dictionary = await AppTranslationService.getAdminDictionary(lang);
      return dictionary;
    } catch (error) {
      reply.code(400).send({ error: error.message });
    }
  }

  static async setDictionary(request, reply) {
    try {
      const { lang } = request.params;
      const dictionary = await AppTranslationService.setDictionary(lang, request.body);
      return dictionary;
    } catch (error) {
      reply.code(400).send({ error: error.message });
    }
  }

  static async removeKey(request, reply) {
    try {
      const { lang, key } = request.params;
      const result = await AppTranslationService.removeKey(lang, key);
      return result;
    } catch (error) {
      reply.code(400).send({ error: error.message });
    }
  }
}
