export const ROLES = {
    ADMIN: 'admin',
    USER: 'user'
}

// Имена справочников — совпадают со значениями name в таблице dictionary_update
// (см. install/steps/3.sql) и используются сервисами, чтобы отмечать время
// последнего изменения каталога.
export const DICTIONARIES = {
    INGREDIENT: 'ingredient',
    RECIPE: 'recipe',
    TAG: 'tag'
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
    DICTIONARIES,
    getFileBaseUrl
}
