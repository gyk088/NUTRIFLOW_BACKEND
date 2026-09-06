-- step 1: base auth tables (user + session) — every new app starts from these

BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE my_user (
    id              uuid DEFAULT uuid_generate_v4(),
    name            VARCHAR(40),
    surname         VARCHAR(40),
    email           VARCHAR(100),
    password        VARCHAR(64),
    role            VARCHAR(40),
    ctime           timestamp(6) with time zone DEFAULT NOW(),
    utime           timestamp(6) with time zone,
    active          boolean DEFAULT true,
    reset_token         VARCHAR(64),
    reset_token_expires timestamp(6) with time zone,

    -- профиль/анкета (результат онбординга)
    sex                 VARCHAR(10),
    age                 SMALLINT,
    height_cm           NUMERIC(5,1),
    weight_kg           NUMERIC(5,1),
    target_weight_kg    NUMERIC(5,1),
    activity_level      VARCHAR(20),
    goal_type           VARCHAR(20),
    manual_calorie_target  INTEGER,
    manual_macro_split     jsonb,
    preferences         jsonb DEFAULT '{}'::jsonb,

    UNIQUE(email),
    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE my_user TO @@DBUSER@@;

COMMENT ON TABLE  my_user       IS 'Таблица пользователей';
COMMENT ON COLUMN my_user.ctime IS 'Дата создания';
COMMENT ON COLUMN my_user.utime IS 'Дата редактирования';
COMMENT ON COLUMN my_user.sex                  IS 'male | female';
COMMENT ON COLUMN my_user.activity_level       IS 'sedentary | light | moderate | active | very-active';
COMMENT ON COLUMN my_user.goal_type            IS 'lose-weight | maintain-weight | gain-weight | build-muscle | eat-healthier';
COMMENT ON COLUMN my_user.manual_calorie_target IS 'Ручной таргет по калориям, если задан — переопределяет расчёт по TDEE';
COMMENT ON COLUMN my_user.manual_macro_split   IS 'Ручной сплит БЖУ {protein, carbs, fat} (доли от 0 до 1), если задан';
COMMENT ON COLUMN my_user.preferences          IS 'jsonb: {dietaryTags[], allergies[], dislikedIngredientIds[], favoriteCuisines[], units}';

CREATE TABLE my_session (
    user_id      uuid REFERENCES my_user(id),
    token        VARCHAR(256),
    fcm_token    VARCHAR(256),
    user_agent   VARCHAR(256),
    ip           VARCHAR(32),
    impersonated_by uuid,
    ctime        timestamp(6) with time zone DEFAULT NOW(),
    utime        timestamp(6) with time zone,

    PRIMARY KEY (user_id, token)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE my_session TO @@DBUSER@@;

COMMENT ON TABLE  my_session          IS 'Таблица сессий';
COMMENT ON COLUMN my_session.token    IS 'токен для авторизации';
COMMENT ON COLUMN my_session.ctime    IS 'Дата создания';
COMMENT ON COLUMN my_session.utime    IS 'Дата обновления';

COMMIT;
