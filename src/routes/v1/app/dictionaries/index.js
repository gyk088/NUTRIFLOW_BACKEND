import DictionaryController from '../../../../controllers/dictionary.js'
import auth from '../../../../hooks/preHendler.js';

export default async function appDictionaryRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, DictionaryController.getAll);
}
