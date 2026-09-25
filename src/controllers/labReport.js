import LabReportService from '../bll/services/LabReportService.js';

export default class LabReportController {
    static async create(request, reply) {
        try {
            const file = await request.file();
            const report = await LabReportService.create(request.user.f.id, file, request.query.lang);
            return report;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async getById(request, reply) {
        try {
            const { id } = request.params;
            const report = await LabReportService.getFullById(id, request.user.f.id);
            return report;
        } catch (error) {
            reply.code(404).send({ error: error.message });
        }
    }

    static async getAll(request, reply) {
        try {
            const reports = await LabReportService.getAll(request.user.f.id);
            return reports;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async remove(request, reply) {
        try {
            const { id } = request.params;
            const result = await LabReportService.remove(id, request.user.f.id);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async getResultHistory(request, reply) {
        try {
            const { name } = request.query;
            const history = await LabReportService.getResultHistory(request.user.f.id, name);
            return history;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
