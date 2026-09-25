-- step 16: lab_result — пояснения по показателю, которые возвращает Gemini
-- (за что отвечает, последствия при нехватке/избытке, в каких продуктах искать).

BEGIN;

ALTER TABLE lab_result ADD COLUMN description  TEXT;
ALTER TABLE lab_result ADD COLUMN low_effects  TEXT;
ALTER TABLE lab_result ADD COLUMN high_effects TEXT;
ALTER TABLE lab_result ADD COLUMN food_sources jsonb DEFAULT '[]'::jsonb;

COMMENT ON COLUMN lab_result.description  IS 'За что отвечает показатель (справочная информация от Gemini, на языке запроса)';
COMMENT ON COLUMN lab_result.low_effects  IS 'Возможные последствия пониженного значения / нехватки';
COMMENT ON COLUMN lab_result.high_effects IS 'Возможные последствия повышенного значения / избытка';
COMMENT ON COLUMN lab_result.food_sources IS 'jsonb-массив продуктов, богатых этим витамином/микроэлементом (пусто, если показатель не нутриентный)';

COMMIT;
