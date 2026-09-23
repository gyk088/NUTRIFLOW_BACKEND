-- step 9: article — статьи (картинка, заголовок, текст из rich-text редактора
-- админки, хранится как HTML) + теги (переиспользуем общую таблицу tag,
-- как recipe_tag) + избранное пользователей.

BEGIN;

CREATE TABLE article (
    id          uuid DEFAULT uuid_generate_v4(),
    title       VARCHAR(200) NOT NULL,
    image_url   VARCHAR(500),
    content     TEXT,
    ctime       timestamp(6) with time zone DEFAULT NOW(),
    utime       timestamp(6) with time zone,

    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE article TO @@DBUSER@@;

COMMENT ON TABLE  article         IS 'Статья';
COMMENT ON COLUMN article.content IS 'HTML из rich-text редактора админки (Tiptap)';
COMMENT ON COLUMN article.ctime   IS 'Дата создания';
COMMENT ON COLUMN article.utime   IS 'Дата обновления';

CREATE TABLE article_tag (
    article_id  uuid REFERENCES article(id),
    tag_id      uuid REFERENCES tag(id),

    PRIMARY KEY (article_id, tag_id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE article_tag TO @@DBUSER@@;

COMMENT ON TABLE article_tag IS 'Связь статьи с тегами';

CREATE TABLE article_favorite (
    user_id     uuid REFERENCES my_user(id),
    article_id  uuid REFERENCES article(id),
    ctime       timestamp(6) with time zone DEFAULT NOW(),

    PRIMARY KEY (user_id, article_id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE article_favorite TO @@DBUSER@@;

COMMENT ON TABLE article_favorite IS 'Избранные статьи пользователя';

COMMIT;
