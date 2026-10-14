-- step 19: добавляем омега-9 к нутриентам ingredient (рядом с omega_3/omega_6
-- из install/steps/2.sql).

BEGIN;

ALTER TABLE ingredient ADD COLUMN omega_9 NUMERIC(10,3) NOT NULL DEFAULT 0;

COMMIT;
