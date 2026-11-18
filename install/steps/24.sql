-- step 24: личные данные пользователя из приложения (дневник питания, вода,
-- избранные рецепты, интервальное голодание).
--
-- Раньше жили только в AsyncStorage телефона и терялись при переустановке
-- или смене устройства. Одна общая таблица на все виды записей: приложение
-- синхронизирует их одинаково (GET /app/user-data?since=, POST /app/user-data/batch),
-- а содержимое записи сервер не разбирает — хранит как есть в data.
--
--   kind       — вид записи: food_log | water | favorite | fast | setting
--                (fast — одно голодание; setting — настройки приложения,
--                 id = раздел, например 'fasting')
--   id         — id записи, который выдал клиент (для favorite — id рецепта)
--   person_id  — NULL — сам пользователь, иначе id члена семьи
--                (preferences.familyMembers[].id)
--   date       — день, к которому относится запись (для food_log/water)
--   utime      — время последнего изменения на сервере, по нему отдаётся дельта
--   deleted_at — мягкое удаление: клиент узнаёт об удалении из дельты
--
-- ON DELETE CASCADE: при удалении аккаунта записи удаляются вместе с ним.

BEGIN;

CREATE TABLE user_entry (
    user_id    uuid        NOT NULL REFERENCES my_user(id) ON DELETE CASCADE,
    kind       text        NOT NULL CHECK (kind IN ('food_log', 'water', 'favorite', 'fast', 'setting')),
    id         text        NOT NULL,
    person_id  text,
    date       date,
    data       jsonb       NOT NULL DEFAULT '{}'::jsonb,
    utime      timestamp(6) with time zone NOT NULL DEFAULT now(),
    deleted_at timestamp(6) with time zone,
    PRIMARY KEY (user_id, kind, id)
);

CREATE INDEX user_entry_user_utime_idx ON user_entry (user_id, utime);

COMMENT ON TABLE  user_entry           IS 'Личные данные из приложения: дневник питания, вода, избранные рецепты, голодание, настройки';
COMMENT ON COLUMN user_entry.kind      IS 'food_log | water | favorite | fast | setting';
COMMENT ON COLUMN user_entry.id        IS 'id записи от клиента (для favorite — id рецепта)';
COMMENT ON COLUMN user_entry.person_id IS 'NULL — сам пользователь, иначе id члена семьи из preferences.familyMembers';
COMMENT ON COLUMN user_entry.data      IS 'Содержимое записи в формате приложения, сервер не разбирает';

COMMIT;
