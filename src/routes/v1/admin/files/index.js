import FileController from '../../../../controllers/file.js'
import auth from '../../../../hooks/preHendler.js';
import { ADMIN_AND_ABOVE } from '../../../../bll/utils/const.js';

export default async function adminFileRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth(ADMIN_AND_ABOVE)]}, FileController.upload);
    fastify.delete('/:filename', {preHandler: [auth(ADMIN_AND_ABOVE)]}, FileController.remove);
}
