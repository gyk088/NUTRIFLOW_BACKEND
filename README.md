# Fastify backend template

Шаблон backend-приложения, вынесенный из `ArtCRM_BACKEND`. Используется как
каркас для новых проектов: Node.js + Fastify + PostgreSQL (raw SQL через
`pgobject`), слоистая архитектура, JWT-подобная авторизация по сессиям.

## Стек

- **Fastify 5** — HTTP-сервер
- **PostgreSQL** + **pgobject** (`PgObject`) — ORM-подобная обёртка без query-билдера:
  модели описывают `schema`/`table`, читают/пишут через `select()`/`save()`/`update()`/`delete()`,
  сложные JOIN'ы — через `PgObject.query(rawSql, params)`
- **bcrypt** — хеширование паролей
- **@fastify/multipart** + **@fastify/static** — загрузка и раздача файлов (папка `files/`)
- **@fastify/view + ejs** — server-rendered публичные страницы (папка `src/views`, см. `ArtCRM_BACKEND` — там есть `collection.ejs`, если нужен пример)
- **nodemailer** — письма (сброс пароля и т.п.)
- Авторизация — не JWT, а **токен сессии в таблице `my_session`**, проверяется в
  `src/hooks/preHendler.js` на каждый запрос (без stateless-верификации)

## Структура папок

```
├── install/                     # ручные SQL-миграции (без ORM-миграций типа Prisma/Knex)
│   ├── createDb.cjs             # создаёт БД (node install/createDb.cjs)
│   ├── migration.cjs            # прогоняет steps/*.sql по порядку номеров
│   ├── complitedSteps.txt       # какие шаги уже выполнены (per-env, в .gitignore)
│   └── steps/
│       ├── 1.sql                # база: my_user + my_session
│       └── 2.sql.example        # шаблон для первой доменной сущности
├── files/                       # загруженные файлы (раздаются статикой, в .gitignore)
├── public/                      # css/js для server-rendered EJS страниц
├── src/
│   ├── index.js                 # точка входа: регистрация плагинов и роутов, коннект к БД
│   ├── hooks/
│   │   └── preHendler.js        # auth(rolesArray?) — preHandler для роутов
│   ├── routes/v1/<entity>/index.js   # только объявление путей + preHandler, вызывает Controller
│   ├── controllers/<entity>.js       # static-методы (request, reply) => try/catch + коды ответа
│   ├── bll/
│   │   ├── models/<Entity>Model.js   # extends PgObject: schema, table, кастомные select-запросы
│   │   ├── services/<Entity>Service.js  # бизнес-логика, проверки прав, работа с несколькими моделями
│   │   └── utils/                    # const.js (роли, env-геттеры), helpers.js, Mailer.js
│   └── views/                   # *.ejs для публичных страниц (если нужны)
├── .env.example
├── compose.yaml                 # postgres + adminer для локальной разработки
├── package.json
└── run.cjs                      # pm2 start (прод)
```

Поток запроса: `routes` → `controllers` (парсинг request/reply, try/catch) →
`bll/services` (бизнес-логика, авторизационные проверки типа "это моя запись?")
→ `bll/models` (SQL). Роуты и контроллеры НЕ обращаются к моделям напрямую.

## Как создать новое приложение из этого шаблона

1. Скопировать папку целиком:
   ```
   cp -r ~/projects/_templates/fastify-backend-template ~/projects/<NEW_APP>_BACKEND
   cd ~/projects/<NEW_APP>_BACKEND
   ```
2. В `package.json` поменять `"name"`, в `run.cjs` — `__APP_NAME__`.
3. `cp .env.example .env`, заполнить `DB_*`, `SMTP_*`, `FASTIFY_PORT`, `FRONTEND_URL`, `FILE_BASE_URL`.
4. `npm install`.
5. Поднять Postgres (`docker compose up -d` из `compose.yaml`, либо использовать существующий инстанс).
6. `npm run db:create` (создаёт БД), затем `npm run db:migrate` (прогоняет `install/steps/1.sql`).
7. Под каждую новую доменную сущность (например "заказ", "проект", "товар"):
   - скопировать и заполнить `src/bll/models/_ExampleModel.js` → `<Entity>Model.js`
   - скопировать `src/bll/services/_ExampleService.js` → `<Entity>Service.js`
   - скопировать `src/controllers/_example.js` → `<entity>.js`
   - скопировать папку `src/routes/v1/_example/` → `src/routes/v1/<entities>/`
   - добавить SQL для новой таблицы как `install/steps/N.sql` (по образцу `steps/2.sql.example`) и прогнать `node install/migration.cjs N`
   - зарегистрировать роут в `src/index.js` (`fastify.register(...)`)
8. `npm run dev` — старт с автоперезагрузкой (nodemon).

## Когда даёшь Claude промт на новое приложение

Опиши сущности (таблицы/поля), роли пользователей и специфичную бизнес-логику
(например: "у сущности Order есть статус, менять статус может только менеджер") —
остальное (auth, структура папок, CRUD-скелет, миграции) собирается по этому шаблону
без лишних вопросов.
