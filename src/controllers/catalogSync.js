import CatalogSyncService from '../bll/services/CatalogSyncService.js';

export default class CatalogSyncController {
    static async sync(request, reply) {
        try {
            const { since, lang } = request.query;
            const result = await CatalogSyncService.sync(since || null, lang, !request.user, request.user?.f.id ?? null);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
