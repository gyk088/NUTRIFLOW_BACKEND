import UserEntryService from '../bll/services/UserEntryService.js';

export default class UserEntryController {
    static async getChanges(request, reply) {
        try {
            return await UserEntryService.getChanges(request.user.f.id, request.query.since || null);
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async applyBatch(request, reply) {
        try {
            return await UserEntryService.applyBatch(request.user.f.id, request.body);
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
