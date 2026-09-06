export const ROLES = {
    ADMIN: 'admin',
    USER: 'user'
}

// Базовый URL раздачи загруженных файлов.
// Читаем process.env лениво, внутри функции, а не в константе на верхнем
// уровне модуля — в src/index.js роуты (а с ними и модели) импортируются
// статически ДО вызова dotenv.config(), поэтому на момент оценки top-level
// кода этих модулей process.env.FILE_BASE_URL ещё не был бы прочитан из .env.
export function getFileBaseUrl() {
    return process.env.FILE_BASE_URL || 'http://localhost:3000/files';
}

export default {
    ROLES,
    getFileBaseUrl
}
