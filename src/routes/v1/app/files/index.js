import FileController from '../../../../controllers/file.js'
import auth from '../../../../hooks/preHendler.js';

// Загрузка картинок любым авторизованным пользователем (не только админом) —
// нужна для фото собственных рецептов (preferences.myRecipes). Тот же
// FileController/FileService, что и у /admin/files: отдаёт только filename,
// см. src/bll/utils/files.js.
export default async function appFileRoutes(fastify, _options) {
    fastify.post('/', {preHandler: [auth()]}, FileController.upload);
}
