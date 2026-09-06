import DictionaryService from '../bll/services/DictionaryService.js';

export default class DictionaryController {
    static async getAll(request, reply) {
        try {
            const dictionaries = await DictionaryService.getAll();
            return dictionaries;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
