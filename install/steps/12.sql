-- step 12: lab_report / lab_result — пользователь загружает PDF/фото анализа
-- из мобильного приложения, бэкенд разбирает его через Gemini API
-- (см. GeminiService) и сохраняет показатели структурированно.

BEGIN;

CREATE TABLE lab_report (
    id            uuid DEFAULT uuid_generate_v4(),
    user_id       uuid REFERENCES my_user(id),
    file_url      VARCHAR(500),
    lab_name      VARCHAR(200),
    taken_at      DATE,
    status        VARCHAR(20) NOT NULL DEFAULT 'processing',
    error_message TEXT,
    raw_response  jsonb,
    ctime         timestamp(6) with time zone DEFAULT NOW(),

    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE lab_report TO @@DBUSER@@;

COMMENT ON TABLE  lab_report               IS 'Загруженный пользователем анализ (PDF/фото), разобранный через Gemini API';
COMMENT ON COLUMN lab_report.file_url      IS 'Ссылка на загруженный оригинал (PDF или изображение)';
COMMENT ON COLUMN lab_report.lab_name      IS 'Название лаборатории/клиники, если распознано';
COMMENT ON COLUMN lab_report.taken_at      IS 'Дата взятия пробы / выдачи результата, если распознана';
COMMENT ON COLUMN lab_report.status        IS 'processing | done | failed';
COMMENT ON COLUMN lab_report.error_message IS 'Текст ошибки, если разбор не удался (status = failed)';
COMMENT ON COLUMN lab_report.raw_response  IS 'Полный JSON-ответ Gemini — для отладки и переразбора без повторного похода в Gemini';

CREATE TABLE lab_result (
    id             uuid DEFAULT uuid_generate_v4(),
    report_id      uuid REFERENCES lab_report(id),
    name           VARCHAR(200) NOT NULL,
    value          VARCHAR(200) NOT NULL,
    value_numeric  NUMERIC(14,4),
    unit           VARCHAR(50),
    ref_range      VARCHAR(100),
    ref_min        NUMERIC(14,4),
    ref_max        NUMERIC(14,4),
    flag           VARCHAR(10),

    PRIMARY KEY (id)
);

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE lab_result TO @@DBUSER@@;

COMMENT ON TABLE  lab_result               IS 'Один показатель одного анализа (напр. "Гемоглобин: 145 г/л, норма 120-160")';
COMMENT ON COLUMN lab_result.name          IS 'Название показателя как напечатано в отчёте';
COMMENT ON COLUMN lab_result.value         IS 'Значение как напечатано в отчёте (включая качественные результаты вроде "отрицательно")';
COMMENT ON COLUMN lab_result.value_numeric IS 'Числовое значение, если value — обычное число — используется для графиков истории показателя';
COMMENT ON COLUMN lab_result.ref_range     IS 'Референсные значения как напечатаны в отчёте';
COMMENT ON COLUMN lab_result.flag          IS 'low | normal | high, если определимо из отчёта';

COMMIT;
