import Fastify from 'fastify'
import userRoutes from './routes/v1/users/index.js'
import authRoutes from './routes/v1/auth/index.js'
import ingredientRoutes from './routes/v1/ingredients/index.js'
import recipeRoutes from './routes/v1/recipes/index.js'
import tagRoutes from './routes/v1/tags/index.js'
import dictionaryRoutes from './routes/v1/dictionaries/index.js'
// import exampleRoutes from './routes/v1/_example/index.js' // раскомментируйте, переименовав папку/файлы под сущность

import fastifyMultipart from '@fastify/multipart'
import fastifyStatic from '@fastify/static'
import fastifyView from '@fastify/view'
import ejs from 'ejs'
import cors from '@fastify/cors'
import { PgObject } from 'pgobject'
import { Pool } from 'pg'
import dotenv from 'dotenv';
import { fileURLToPath } from 'url'
import path from 'path'
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config();

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

fastify.register(userRoutes, { prefix: '/api/v1/users' })
fastify.register(authRoutes, { prefix: '/api/v1/auth' })
fastify.register(ingredientRoutes, { prefix: '/api/v1/ingredients' })
fastify.register(recipeRoutes, { prefix: '/api/v1/recipes' })
fastify.register(tagRoutes, { prefix: '/api/v1/tags' })
fastify.register(dictionaryRoutes, { prefix: '/api/v1/dictionaries' })
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
