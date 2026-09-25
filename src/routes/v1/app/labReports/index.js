import LabReportController from '../../../../controllers/labReport.js'
import auth from '../../../../hooks/preHendler.js';

// Полностью пользовательская сущность — своих анализов, поэтому только под
// /app, без /admin: разбор запускает сам пользователь при загрузке файла.
export default async function appLabReportRoutes(fastify, _options) {
    fastify.get('/', {preHandler: [auth()]}, LabReportController.getAll);
    fastify.get('/results/history', {preHandler: [auth()]}, LabReportController.getResultHistory);
    fastify.get('/:id', {preHandler: [auth()]}, LabReportController.getById);
    fastify.post('/', {preHandler: [auth()]}, LabReportController.create);
    fastify.delete('/:id', {preHandler: [auth()]}, LabReportController.remove);
}
