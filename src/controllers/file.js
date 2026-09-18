import FileService from '../bll/services/FileService.js';

export default class FileController {
    static async upload(request, reply) {
        try {
            const data = await request.file();
            const result = await FileService.upload(data);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }

    static async remove(request, reply) {
        try {
            const result = await FileService.remove(request.params.filename);
            return result;
        } catch (error) {
            reply.code(400).send({ error: error.message });
        }
    }
}
