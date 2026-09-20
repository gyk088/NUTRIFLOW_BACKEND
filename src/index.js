import './env.js'
import Fastify from 'fastify'
import authRoutes from './routes/v1/auth/index.js'
// Для мобильного приложения — только чтение каталогов + свой профиль (auth()).
import appUserRoutes from './routes/v1/app/users/index.js'
import appIngredientRoutes from './routes/v1/app/ingredients/index.js'
import appRecipeRoutes from './routes/v1/app/recipes/index.js'
import appTagRoutes from './routes/v1/app/tags/index.js'
import appDictionaryRoutes from './routes/v1/app/dictionaries/index.js'
import appSyncRoutes from './routes/v1/app/sync/index.js'
// Для админ-панели — запись контента + управление пользователями (admin+/super_admin).
import adminUserRoutes from './routes/v1/admin/users/index.js'
import adminIngredientRoutes from './routes/v1/admin/ingredients/index.js'
import adminRecipeRoutes from './routes/v1/admin/recipes/index.js'
import adminTagRoutes from './routes/v1/admin/tags/index.js'
import adminFileRoutes from './routes/v1/admin/files/index.js'
// import exampleRoutes from './routes/v1/_example/index.js' // раскомментируйте, переименовав папку/файлы под сущность

import fastifyMultipart from '@fastify/multipart'
import fastifyStatic from '@fastify/static'
import fastifyView from '@fastify/view'
import ejs from 'ejs'
import cors from '@fastify/cors'
import PgObject from 'pgobject';
import { Pool } from 'pg'
import { fileURLToPath } from 'url'
import path from 'path'
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const fastify = Fastify({
  logger: true,
  // За nginx-реверс-прокси — иначе request.protocol всегда 'http'
  trustProxy: true
})

fastify.register(fastifyMultipart, {
  limits: {
    fileSize: 5 * 1024 * 1024 // 5 МБ
  }
})

await fastify.register(cors, {
  origin: true, // TODO: сузить до конкретных доменов в проде
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
})

// раздача загруженных файлов
await fastify.register(fastifyStatic, {
  root: path.join(__dirname, '..', 'files'),
  prefix: '/files/',
})

// статика (css/js) для серверно рендерённых публичных страниц
await fastify.register(fastifyStatic, {
  root: path.join(__dirname, '..', 'public'),
  prefix: '/static/',
  decorateReply: false,
})

// шаблонизатор для серверно рендерённых публичных страниц (см. src/views)
await fastify.register(fastifyView, {
  engine: { ejs },
  root: path.join(__dirname, 'views'),
})

fastify.register(authRoutes, { prefix: '/api/v1/auth' })

fastify.register(appUserRoutes, { prefix: '/api/v1/app/users' })
fastify.register(appIngredientRoutes, { prefix: '/api/v1/app/ingredients' })
fastify.register(appRecipeRoutes, { prefix: '/api/v1/app/recipes' })
fastify.register(appTagRoutes, { prefix: '/api/v1/app/tags' })
fastify.register(appDictionaryRoutes, { prefix: '/api/v1/app/dictionaries' })
fastify.register(appSyncRoutes, { prefix: '/api/v1/app/sync' })

fastify.register(adminUserRoutes, { prefix: '/api/v1/admin/users' })
fastify.register(adminIngredientRoutes, { prefix: '/api/v1/admin/ingredients' })
fastify.register(adminRecipeRoutes, { prefix: '/api/v1/admin/recipes' })
fastify.register(adminTagRoutes, { prefix: '/api/v1/admin/tags' })
fastify.register(adminFileRoutes, { prefix: '/api/v1/admin/files' })
// fastify.register(exampleRoutes, { prefix: '/api/v1/items' })

function connectToDatabase() {
  const client = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASS,
    port: process.env.DB_PORT,
  });
  PgObject.setClient(client);
  PgObject.setLog(true);
}

const start = async () => {
  try {
    connectToDatabase();
    await fastify.listen({ port: process.env.FASTIFY_PORT, host: '0.0.0.0' })
    console.log(`Server is running on http://localhost:${process.env.FASTIFY_PORT}`)
  } catch (err) {
    fastify.log.error(err)
    process.exit(1)
  }
}
start()
