-- step 14: историю веса храним в my_user.preferences.weightHistory (jsonb-массив
-- [{ weight_kg, ctime }] по возрастанию даты), а не в отдельной таблице.
-- Накопленные записи user_weight_log переносятся, после чего таблица удаляется.

BEGIN;

UPDATE my_user u
SET preferences = COALESCE(u.preferences, '{}'::jsonb) || jsonb_build_object('weightHistory', h.items)
FROM (
    SELECT user_id,
           jsonb_agg(
               jsonb_build_object(
                   'weight_kg', weight_kg,
                   'ctime', to_char(ctime AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
               ) ORDER BY ctime
           ) AS items
    FROM user_weight_log
    GROUP BY user_id
) h
WHERE u.id = h.user_id;

DROP TABLE user_weight_log;

COMMENT ON COLUMN my_user.preferences IS 'jsonb: {dietaryTags[], allergies[], dislikedIngredientIds[], favoriteCuisines[], units, weightHistory[]}. weightHistory — [{weight_kg, ctime}], ведётся сервером при смене weight_kg, клиентом не перезаписывается';

COMMIT;
