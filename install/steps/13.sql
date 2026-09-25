-- step 13: user_weight_log — история изменений веса пользователя с датами.
-- Запись добавляется сервисным слоем при каждом изменении my_user.weight_kg
-- (см. UserService.updateProfile); сам my_user.weight_kg остаётся текущим значением.

BEGIN;

CREATE TABLE user_weight_log (
    id         uuid DEFAULT uuid_generate_v4(),
    user_id    uuid NOT NULL REFERENCES my_user(id),
    weight_kg  NUMERIC(5,1) NOT NULL,
    ctime      timestamp(6) with time zone DEFAULT NOW(),

    PRIMARY KEY (id)
);

CREATE INDEX user_weight_log_user_ctime_idx ON user_weight_log (user_id, ctime);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE user_weight_log TO @@DBUSER@@;

COMMENT ON TABLE  user_weight_log           IS 'История веса пользователя: одна строка на каждое изменение weight_kg';
COMMENT ON COLUMN user_weight_log.ctime     IS 'Когда вес был записан';

-- Стартовая точка истории для уже существующих пользователей
INSERT INTO user_weight_log (user_id, weight_kg, ctime)
SELECT id, weight_kg, COALESCE(utime, ctime) FROM my_user WHERE weight_kg IS NOT NULL;

COMMIT;
