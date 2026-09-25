-- step 15: история изменений всех полей анкеты — my_user.preferences.history
-- ({ <поле>: [{ value, ctime }] }, ведёт сервер). Заменяет preferences.weightHistory
-- из шага 14: она переносится в history.weight_kg.

BEGIN;

UPDATE my_user u
SET preferences = (u.preferences - 'weightHistory') || jsonb_build_object(
    'history',
    COALESCE(u.preferences->'history', '{}'::jsonb) || jsonb_build_object(
        'weight_kg',
        (SELECT jsonb_agg(jsonb_build_object('value', e->'weight_kg', 'ctime', e->'ctime'))
         FROM jsonb_array_elements(u.preferences->'weightHistory') e)
    )
)
WHERE jsonb_typeof(u.preferences->'weightHistory') = 'array'
  AND jsonb_array_length(u.preferences->'weightHistory') > 0;

UPDATE my_user SET preferences = preferences - 'weightHistory' WHERE preferences ? 'weightHistory';

COMMENT ON COLUMN my_user.preferences IS 'jsonb: {dietaryTags[], allergies[], dislikedIngredientIds[], favoriteCuisines[], units, history{}}. history — { <поле анкеты>: [{value, ctime}] }, ведётся сервером при изменении поля, клиентом не перезаписывается';

COMMIT;
