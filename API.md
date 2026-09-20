# NUTRIFLOW_BACKEND — список эндпоинтов

Базовый URL: `http://<host>:3000/api/v1`

Авторизация — заголовок `Authorization: Bearer <token>` (токен из `session.token`,
выдаётся `/auth/login`, `/auth/register`, `/auth/google`).

Роуты физически разделены по типу клиента:

- **`/api/v1/app/*`** — для мобильного приложения. Только чтение каталогов + свой профиль.
  Доступно любому авторизованному пользователю (`auth()`), без требований к роли.
- **`/api/v1/admin/*`** — для админ-панели. Запись контента и управление пользователями.
  Требует роль `admin`/`super_admin` (или только `super_admin` — отмечено отдельно).
- **`/api/v1/auth/*`** — общее для обоих клиентов (вход/сессии), под конкретный тип не относится.

Админ-панель поэтому дёргает оба префикса: читает списки/карточки через `/app/*`,
пишет — через `/admin/*`.

## Auth — `/api/v1/auth` (общее)

| Метод | Путь | Доступ | Тело запроса | Описание |
|---|---|---|---|---|
| POST | `/login` | Публичный | `{ email, password }` | Логин, возвращает `{ session, user }` |
| POST | `/register` | Публичный | `{ email, password }` | Регистрация, возвращает `{ session, user }` |
| POST | `/google` | Публичный | `{ idToken }` | Вход через Google (верификация ID-токена) |
| POST | `/forgot-password` | Публичный | `{ email }` | Отправка письма со ссылкой сброса пароля |
| POST | `/reset-password` | Публичный | `{ token, password }` | Сброс пароля по токену из письма |
| POST | `/change-password` | Авторизован | `{ currentPassword, newPassword }` | Смена пароля |
| GET | `/sessions` | Авторизован | — | Список активных сессий пользователя |
| POST | `/sessions/revoke` | Авторизован | `{ token }` | Отозвать конкретную сессию (логаут) |
| POST | `/sessions/revoke-others` | Авторизован | — | Отозвать все сессии, кроме текущей |

## `/api/v1/app/*` — мобильное приложение

| Метод | Путь | Доступ | Тело запроса | Описание |
|---|---|---|---|---|
| GET | `/users/me` | Авторизован | — | Свой профиль |
| PUT | `/users/me` | Авторизован | `{ name, sex, age, height_cm, weight_kg, target_weight_kg, activity_level, goal_type, manual_calorie_target, manual_macro_split, preferences }` | Обновить свой профиль (анкета онбординга) |
| GET | `/ingredients?search=` | Авторизован | — | Список ингредиентов |
| GET | `/ingredients/:id` | Авторизован | — | Один ингредиент + теги (аллергены) |
| GET | `/recipes?search=` | Авторизован | — | Список рецептов |
| GET | `/recipes/:id` | Авторизован | — | Полный рецепт: состав, теги, посчитанное КБЖУ |
| GET | `/sync?since=<ISO-дата>` | Авторизован | — | Инкрементальная синхронизация: рецепты/ингредиенты/теги, изменённые после `since` (без `since` — весь текущий каталог). Ответ: `{ recipes, ingredients, tags, syncedAt }` — `syncedAt` нужно сохранить на клиенте и передавать как `since` в следующий раз |
| GET | `/tags?type=` | Авторизован | — | Список тегов (фильтр по типу) |
| GET | `/tags/:id` | Авторизован | — | Один тег |
| GET | `/dictionaries` | Авторизован | — | Время последнего изменения каждого справочника — для инкрементальной синхронизации |

## `/api/v1/admin/*` — админ-панель

| Метод | Путь | Доступ | Тело запроса | Описание |
|---|---|---|---|---|
| GET | `/users` | super_admin | — | Список всех пользователей |
| PUT | `/users/:id/role` | super_admin | `{ role }` | Смена роли (`user`/`admin`/`super_admin`); нельзя менять свою же роль |
| POST | `/ingredients` | admin+ | `{ name_ru, name_en, image_url, grams_per_unit, tagIds, ...34 нутриентных поля }` | Создать ингредиент |
| PUT | `/ingredients/:id` | admin+ | те же поля, частично | Обновить |
| DELETE | `/ingredients/:id` | admin+ | — | Удалить |
| POST | `/recipes` | admin+ | `{ name_ru, name_en, description_ru/en, cook_time_ru/en, steps_ru/en, image_url, servings, tagIds: [], ingredients: [{ ingredient_id, quantity, unit }] }` | Создать рецепт с составом |
| PUT | `/recipes/:id` | admin+ | те же поля, частично | Обновить (состав/теги перезаписываются, если переданы) |
| DELETE | `/recipes/:id` | admin+ | — | Удалить |
| POST | `/tags` | admin+ | `{ type, name_ru, name_en }` | Создать тег |
| PUT | `/tags/:id` | admin+ | `{ type, name_ru, name_en }` | Обновить |
| DELETE | `/tags/:id` | admin+ | — | Удалить |
| POST | `/files` | admin+ | `multipart/form-data`, поле `file` (jpeg/png/webp/gif, ≤5 МБ) | Загрузка картинки, возвращает `{ url, filename }` |
| DELETE | `/files/:filename` | admin+ | — | Удалить загруженный файл |

## Статика

| Метод | Путь | Доступ | Описание |
|---|---|---|---|
| GET | `/files/:filename` | Публичный | Раздача загруженных файлов (не под `/api/v1`, без авторизации) |

## Не зарегистрировано

- `src/routes/v1/_example/index.js` — шаблон-заглушка из fastify-backend-template, закомментирован в `src/index.js`, реально не подключён.

---
Всего активных эндпоинтов: **32** (9 auth + 10 app + 13 admin), плюс статика для файлов.

## Структура файлов роутов

```
src/routes/v1/
├── auth/index.js               # общее
├── app/
│   ├── users/index.js          # GET/PUT /me
│   ├── ingredients/index.js    # GET /, GET /:id
│   ├── recipes/index.js        # GET /, GET /:id
│   ├── tags/index.js           # GET /, GET /:id
│   ├── dictionaries/index.js   # GET /
│   └── sync/index.js           # GET /?since= — инкрементальная синхронизация
└── admin/
    ├── users/index.js          # GET /, PUT /:id/role (super_admin)
    ├── ingredients/index.js    # POST /, PUT /:id, DELETE /:id
    ├── recipes/index.js        # POST /, PUT /:id, DELETE /:id
    ├── tags/index.js           # POST /, PUT /:id, DELETE /:id
    └── files/index.js          # POST /, DELETE /:filename
```

Контроллеры и сервисы (`src/controllers/*`, `src/bll/services/*`) не дублируются —
`app` и `admin` роуты для одной сущности вызывают одни и те же контроллеры,
различаются только набором HTTP-методов и требованием к роли в `auth([...])`.
