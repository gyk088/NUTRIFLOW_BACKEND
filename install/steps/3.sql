-- step 3: dictionary_update — время последнего изменения каждого справочника
-- (ingredient, recipe, tag). Клиент опрашивает эту таблицу, чтобы понять,
-- нужно ли перекачивать каталог заново, не забирая весь справочник целиком.

BEGIN;

CREATE TABLE dictionary_update (
    name    VARCHAR(40),
    utime   timestamp(6) with time zone DEFAULT NOW(),

    PRIMARY KEY (name)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dictionary_update TO @@DBUSER@@;

COMMENT ON TABLE  dictionary_update       IS 'Время последнего изменения справочника — обновляется сервисным слоем при любом create/update/delete в этом справочнике';
COMMENT ON COLUMN dictionary_update.name  IS 'Имя справочника: ingredient | recipe | tag';
COMMENT ON COLUMN dictionary_update.utime IS 'Время последнего изменения справочника';

COMMIT;
