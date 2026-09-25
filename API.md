# NUTRIFLOW_BACKEND — список эндпоинтов

Базовый URL: `http://<host>:3000/api/v1`

Авторизация — заголовок `Authorization: Bearer <token>` (токен из `session.token`,
выдаётся `/auth/login`, `/auth/register`, `/auth/google`, `/auth/apple`).

Роуты физически разделены по типу клиента:

- **`/api/v1/app/*`** — для мобильного приложения. Только чтение каталогов + свой профиль.
  Доступно любому авторизованному пользователю (`auth()`), без требований к роли.
- **`/api/v1/admin/*`** — для админ-панели. Запись контента и управление пользователями.
  Требует роль `admin`/`super_admin` (или только `super_admin` — отмечено отдельно).
- **`/api/v1/auth/*`** — общее для обоих клиентов (вход/сессии), под конкретный тип не относится.

Админ-панель поэтому дёргает оба префикса: читает списки/карточки через `/app/*`,
пишет — через `/admin/*`.

## Языковая модель (ingredient / recipe / tag / article)

У этих четырёх сущностей нет фиксированных колонок `name_ru`/`name_en` — вместо
этого есть управляемый из админки список языков (`/api/v1/admin/languages`) и
отдельная таблица `<entity>_translation` на каждую сущность: **каждый перевод —
своя строка со своим id**, привязанная к языконезависимой базовой записи
(картинка, состав рецепта, нутриенты ингредиента, связи с тегами/избранным не
дублируются на каждый язык).

- Все `GET`-эндпоинты чтения (`/app/.../`, `/app/.../:id`) принимают `?lang=<code>`
  и резолвят перевод под этот язык **с fallback на язык по умолчанию**, если
  перевода на запрошенный язык ещё нет. Без `?lang=` тоже применяется язык по
  умолчанию. Ответ, помимо резолвленных полей, всегда содержит `language`
  (код реально отданного перевода) и `availableLanguages` (все языки, на
  которые сущность переведена).
- Создание (`POST /admin/...`) — тело включает `languageCode` и поля перевода
  для этого языка; создаётся базовая запись + один перевод.
- Добавить/обновить перевод на другой язык: `PUT /admin/.../:id/translations/:lang`.
- Удалить перевод: `DELETE /admin/.../:id/translations/:lang` — нельзя удалить
  последний оставшийся перевод сущности.
- `GET /admin/.../:id` — отдельный эндпоинт для админки, отдаёт **все** переводы
  сразу (`translations: [...]`), без резолва под один язык — нужен форме
  редактирования, где вкладки по языкам показываются одновременно.

## Разбор анализов через Gemini (`lab-reports`)

Пользователь загружает фото или PDF лабораторного анализа через
`POST /app/lab-reports` — бэкенд сохраняет файл (как обычная загрузка,
см. `FileService`/`saveUploadedFile`) и **синхронно**, в рамках того же
запроса, отправляет его в Gemini API (`GeminiService`, модель задаётся
`GEMINI_MODEL`, по умолчанию `gemini-flash-latest`) с JSON-схемой ответа —
показатели приходят структурированно (`name`, `value`, `value_numeric`,
`unit`, `ref_range`, `ref_min`/`ref_max`, `flag`), без своего OCR/парсера.
Проверено вживую на реальном ключе: лаборатория, дата и все показатели
(включая качественные результаты и flag low/high по стрелкам в бланке)
распознаются корректно.

- Помимо самих значений Gemini для **каждого** показателя возвращает справочные пояснения на языке `?lang=`: `description` (за что отвечает), `low_effects` (возможные последствия при пониженном значении/нехватке), `high_effects` (при повышенном/избытке) и `food_sources` (массив продуктов, богатых этим витамином/микроэлементом; `[]`, если показатель не нутриентный, напр. лейкоциты). Промт запрещает диагнозы, лечение и дозировки — это общая справочная информация. Старые отчёты (до появления этих полей) содержат `null`/`[]`.
- Требует `GEMINI_API_KEY` в `.env` (ключ из
  [Google AI Studio](https://aistudio.google.com/apikey)). `GEMINI_MODEL`
  стоит держать алиасом (`gemini-flash-latest`), а не конкретной версией —
  Google регулярно снимает старые версии с поддержки для новых ключей
  (`gemini-1.5-flash`, а следом и `gemini-2.5-flash` на практике оказались
  недоступны свежему ключу).
- Любая ошибка Gemini не роняет запрос: неверный/отсутствующий ключ,
  недоступная модель, а изредка и невалидный JSON в ответе самой модели
  (случается под большим бюджетом на "размышление" — тогда повторная
  загрузка обычно проходит нормально) — во всех случаях `lab_report`
  создаётся со `status: "failed"` и текстом ошибки в `error_message`, файл
  не теряется. Переразобрать существующий отчёт повторно (без повторной
  загрузки файла) пока нельзя, это естественное следующее расширение
  (`raw_response` уже хранит сырой ответ Gemini на случай, если понадобится).
- Данные полностью приватны пользователю: `lab_report.user_id` проверяется на
  каждый `GET`/`DELETE`, чужой/несуществующий отчёт всегда отдаёт **404**
  (а не 403 — чтобы не подтверждать сам факт существования чужого id).
- Названия показателей не нормализуются между отчётами (напр. "Гемоглобин" и
  "HGB" — разные строки для `/results/history`) — сопоставление одинаковых
  показателей из разных лабораторий в единый каталог показателей в API пока
  не реализовано.
- `taken_at` — колонка `DATE`; глобально в `src/index.js` отключён дефолтный
  парсинг `pg` в JS `Date` (`types.setTypeParser(1082, v => v)`), иначе дата
  может сместиться на день при сериализации в JSON из-за таймзоны сервера.
  Это касается любой будущей `DATE`-колонки в проекте, не только этой.

## Auth — `/api/v1/auth` (общее)

| Метод | Путь | Доступ | Тело запроса | Описание |
|---|---|---|---|---|
| POST | `/login` | Публичный | `{ email, password }` | Логин, возвращает `{ session, user }` |
| POST | `/register` | Публичный | `{ email, password }` | Регистрация, возвращает `{ session, user }` |
| POST | `/google` | Публичный | `{ idToken }` | Вход через Google (верификация ID-токена). Возвращает `{ session, user, isNewUser }` — `isNewUser: true`, если аккаунт создан именно этим запросом (клиент показывает terms только в этом случае) |
| POST | `/apple` | Публичный | `{ identityToken, email?, fullName? }` | Вход через Sign in with Apple (верификация JWT против ключей Apple); `email`/`fullName` приходят от клиента только при первом входе и сохраняются, если пользователь новый — матчинг по `sub` из токена, а не по email. Возвращает `{ session, user, isNewUser }` — `isNewUser: true`, если аккаунт создан именно этим запросом (клиент показывает terms только в этом случае) |
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
| PUT | `/users/me` | Авторизован | `{ name, sex, age, height_cm, weight_kg, target_weight_kg, activity_level, goal_type, manual_calorie_target, manual_macro_split, preferences }` | Обновить свой профиль (анкета онбординга). Каждое реальное изменение поля анкеты (`sex`, `age`, `height_cm`, `weight_kg`, `target_weight_kg`, `activity_level`, `goal_type`, `manual_calorie_target`, `manual_macro_split`; включая первое заполнение) дописывается в `preferences.history` — `{ <поле>: [{ value, ctime }] }`; повторная отправка тех же значений записей не создаёт. `preferences` заменяются целиком, но `history` ведёт только сервер — присланное клиентом значение этого ключа игнорируется (`preferences` должен быть объектом). **Члены семьи**: `preferences.familyMembers = [{ id, profile }]` (`id` — строка от клиента, `profile` — объект в формате приложения, хранится как есть; до 20 штук, id уникальны). Ключ обрабатывается только если прислан: без него текущие члены семьи сохраняются, `[]` очищает список, отсутствующие в новом списке удаляются. Сервер сам ведёт для каждого члена `history` (`{ sex, age, heightCm, weightKg, targetWeightKg, activityLevel, goalType: [{ value, ctime }] }` — при реальном изменении поля профиля, включая первое заполнение); присланный клиентом `history` игнорируется. Читается в `GET /users/me` → `preferences.familyMembers[].history`. Невалидная структура → 400. `manual_macro_split` — jsonb `{protein, carbs, fat}` (доли 0–1), хранится как есть, без валидации |
| GET | `/users/me/history?field=` | Авторизован | — | История изменений полей анкеты из `preferences.history`: без `field` — вся `{ <поле>: [{ value, ctime }] }`, с `field` — массив по одному полю (400 на неизвестное поле). То же клиент видит и в `GET /users/me` |
| GET | `/users/me/weight-history` | Авторизован | — | Сокращение для истории веса: `[{ weight_kg, ctime }]` по возрастанию даты |
| GET | `/ingredients?search=&lang=` | Авторизован | — | Список ингредиентов, резолвленных на `lang`. У каждого есть `default_unit` — в чём его измерять по умолчанию (штуки, граммы, мл...) |
| GET | `/ingredients/:id?lang=` | Авторизован | — | Один ингредиент + теги (аллергены), резолвленные на `lang` |
| GET | `/recipes?search=&lang=` | Авторизован | — | Список рецептов, резолвленных на `lang` |
| GET | `/recipes/:id?lang=` | Авторизован | — | Полный рецепт: состав (названия ингредиентов на `lang`), теги, посчитанное КБЖУ |
| GET | `/articles?search=&lang=` | Авторизован | — | Список статей, резолвленных на `lang`, с `isFavorite` |
| GET | `/articles/favorites?lang=` | Авторизован | — | Избранные статьи текущего пользователя |
| GET | `/articles/:id?lang=` | Авторизован | — | Одна статья + теги + `isFavorite` |
| POST | `/articles/:id/favorite` | Авторизован | — | Добавить статью в избранное |
| DELETE | `/articles/:id/favorite` | Авторизован | — | Убрать статью из избранного |
| GET | `/tags?type=&lang=` | Авторизован | — | Список тегов (фильтр по типу), резолвленных на `lang` |
| GET | `/tags/:id?lang=` | Авторизован | — | Один тег |
| GET | `/languages` | Публичный | — | Список настроенных языков `[{ code, name, is_default }]` — без авторизации, т.к. экран выбора языка показывается до логина/регистрации |
| GET | `/sync?since=<ISO-дата>&lang=` | Авторизован | — | Инкрементальная синхронизация: рецепты/ингредиенты/теги (резолвленные на `lang`), изменённые после `since` (без `since` — весь текущий каталог). Ответ: `{ recipes, ingredients, tags, syncedAt }` — `syncedAt` нужно сохранить на клиенте и передавать как `since` в следующий раз |
| GET | `/dictionaries` | Авторизован | — | Время последнего изменения каждого справочника — для инкрементальной синхронизации |
| POST | `/lab-reports?lang=` | Авторизован | `multipart/form-data`, поле `file` (jpeg/png/webp/pdf, ≤5 МБ) | Загрузить анализ — сохраняет файл и синхронно разбирает его через Gemini API (см. раздел «Разбор анализов через Gemini» ниже). Возвращает отчёт сразу, включая распознанные показатели или ошибку разбора. `lang` — код языка (из `/languages`) для справочных пояснений; без него или для неизвестного кода — язык по умолчанию |
| GET | `/lab-reports` | Авторизован | — | Список своих отчётов (без показателей), новые сверху |
| GET | `/lab-reports/:id` | Авторизован | — | Один отчёт + все распознанные показатели. 404, если отчёт чужой |
| DELETE | `/lab-reports/:id` | Авторизован | — | Удалить отчёт (и файл с диска). 400, если отчёт чужой |
| GET | `/lab-reports/results/history?name=` | Авторизован | — | История значений одного показателя (по точному названию `name`, как его вернул Gemini) по всем успешно разобранным отчётам пользователя — для графика на клиенте |

## `/api/v1/admin/*` — админ-панель

| Метод | Путь | Доступ | Тело запроса | Описание |
|---|---|---|---|---|
| GET | `/users` | super_admin | — | Список всех пользователей |
| PUT | `/users/:id/role` | super_admin | `{ role }` | Смена роли (`user`/`admin`/`super_admin`); нельзя менять свою же роль |
| POST | `/ingredients` | admin+ | `{ languageCode, name, image_url, default_unit, grams_per_unit, tagIds, ...34 нутриентных поля }` | Создать ингредиент + первый перевод. `default_unit` — единица измерения по умолчанию: `g`, `kg`, `ml`, `l`, `piece`, `tbsp`, `tsp`, `cup`, `slice`, `clove` (по умолчанию `g`); для не-весовых (`piece`, `tbsp`...) обязателен вес одной единицы в `grams_per_unit` (напр. `{ "piece": 55 }`) — иначе 400. Нутриенты по-прежнему заданы на 100 г/мл |
| GET | `/ingredients/:id` | admin+ | — | Все переводы ингредиента (`translations: [{ language_code, name }]`) + базовые поля — для формы редактирования |
| PUT | `/ingredients/:id` | admin+ | `{ image_url, default_unit, grams_per_unit, tagIds, ...нутриенты }` | Обновить базовые (языконезависимые) поля (`default_unit` проверяется так же, как при создании) |
| PUT | `/ingredients/:id/translations/:lang` | admin+ | `{ name }` | Добавить/обновить перевод названия на `lang` |
| DELETE | `/ingredients/:id/translations/:lang` | admin+ | — | Удалить перевод (нельзя удалить последний) |
| DELETE | `/ingredients/:id` | admin+ | — | Удалить ингредиент целиком (все переводы) |
| POST | `/recipes` | admin+ | `{ languageCode, name, description, cook_time, steps, image_url, servings, tagIds: [], ingredients: [{ ingredient_id, quantity, unit }] }` | Создать рецепт + первый перевод + состав |
| GET | `/recipes/:id` | admin+ | — | Все переводы рецепта + состав + теги + КБЖУ — для формы редактирования |
| PUT | `/recipes/:id` | admin+ | `{ image_url, servings, tagIds, ingredients }` | Обновить базовые поля (состав/теги перезаписываются, если переданы) |
| PUT | `/recipes/:id/translations/:lang` | admin+ | `{ name, description, cook_time, steps }` | Добавить/обновить перевод на `lang` |
| DELETE | `/recipes/:id/translations/:lang` | admin+ | — | Удалить перевод (нельзя удалить последний) |
| DELETE | `/recipes/:id` | admin+ | — | Удалить рецепт целиком |
| POST | `/articles` | admin+ | `{ languageCode, title, content, image_url, tagIds }` | Создать статью + первый перевод |
| GET | `/articles/:id` | admin+ | — | Все переводы статьи + базовые поля — для формы редактирования |
| PUT | `/articles/:id` | admin+ | `{ image_url, tagIds }` | Обновить базовые поля |
| PUT | `/articles/:id/translations/:lang` | admin+ | `{ title, content }` | Добавить/обновить перевод на `lang` (`content` — HTML из rich-text редактора админки) |
| DELETE | `/articles/:id/translations/:lang` | admin+ | — | Удалить перевод (нельзя удалить последний) |
| DELETE | `/articles/:id` | admin+ | — | Удалить статью целиком |
| POST | `/tags` | admin+ | `{ languageCode, type, name }` | Создать тег + первый перевод |
| GET | `/tags/:id` | admin+ | — | Все переводы тега — для формы редактирования |
| PUT | `/tags/:id` | admin+ | `{ type }` | Обновить тип |
| PUT | `/tags/:id/translations/:lang` | admin+ | `{ name }` | Добавить/обновить перевод на `lang` |
| DELETE | `/tags/:id/translations/:lang` | admin+ | — | Удалить перевод (нельзя удалить последний) |
| DELETE | `/tags/:id` | admin+ | — | Удалить тег целиком |
| POST | `/languages` | admin+ | `{ code, name, is_default? }` | Добавить язык |
| PUT | `/languages/:code` | admin+ | `{ name?, is_default? }` | Переименовать / сделать языком по умолчанию (снять флаг напрямую нельзя — назначьте другой язык по умолчанию) |
| DELETE | `/languages/:code` | admin+ | — | Удалить язык (нельзя удалить язык по умолчанию или язык, на который ещё есть переводы) |
| POST | `/files` | admin+ | `multipart/form-data`, поле `file` (jpeg/png/webp/gif, ≤5 МБ) | Загрузка картинки, возвращает `{ url, filename }` |
| DELETE | `/files/:filename` | admin+ | — | Удалить загруженный файл |

## Статика

| Метод | Путь | Доступ | Описание |
|---|---|---|---|
| GET | `/files/:filename` | Публичный | Раздача загруженных файлов (не под `/api/v1`, без авторизации) |

## Не зарегистрировано

- `src/routes/v1/_example/index.js` — шаблон-заглушка из fastify-backend-template, закомментирован в `src/index.js`, реально не подключён.

---
Всего активных эндпоинтов: **64** (10 auth + 23 app + 31 admin), плюс статика для файлов.

## Структура файлов роутов

```
src/routes/v1/
├── auth/index.js               # общее (login/register/google/apple/sessions)
├── app/
│   ├── users/index.js          # GET/PUT /me, GET /me/history, GET /me/weight-history
│   ├── ingredients/index.js    # GET /, GET /:id
│   ├── recipes/index.js        # GET /, GET /:id
│   ├── articles/index.js       # GET /, GET /favorites, GET /:id, POST|DELETE /:id/favorite
│   ├── labReports/index.js     # GET /, GET /results/history, GET /:id, POST /, DELETE /:id
│   ├── tags/index.js           # GET /, GET /:id
│   ├── languages/index.js      # GET / (публично, без auth())
│   ├── dictionaries/index.js   # GET /
│   └── sync/index.js           # GET /?since=&lang= — инкрементальная синхронизация
└── admin/
    ├── users/index.js          # GET /, PUT /:id/role (super_admin)
    ├── ingredients/index.js    # POST /, GET /:id, PUT /:id, PUT|DELETE /:id/translations/:lang, DELETE /:id
    ├── recipes/index.js        # POST /, GET /:id, PUT /:id, PUT|DELETE /:id/translations/:lang, DELETE /:id
    ├── articles/index.js       # POST /, GET /:id, PUT /:id, PUT|DELETE /:id/translations/:lang, DELETE /:id
    ├── tags/index.js           # POST /, GET /:id, PUT /:id, PUT|DELETE /:id/translations/:lang, DELETE /:id
    ├── languages/index.js      # POST /, PUT /:code, DELETE /:code
    └── files/index.js          # POST /, DELETE /:filename
```

Контроллеры и сервисы (`src/controllers/*`, `src/bll/services/*`) не дублируются —
`app` и `admin` роуты для одной сущности вызывают одни и те же контроллеры,
различаются только набором HTTP-методов и требованием к роли в `auth([...])`.
