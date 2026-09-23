-- step 8: Sign in with Apple — учётные записи матчатся по стабильному Apple
-- `sub`, а не по email: email/fullName Apple присылает клиенту только при
-- самом первом входе, при повторных их может не быть вовсе.

BEGIN;

ALTER TABLE my_user ADD COLUMN apple_id VARCHAR(255) UNIQUE;

COMMENT ON COLUMN my_user.apple_id IS 'Apple `sub` (стабильный уникальный id пользователя от Sign in with Apple)';

COMMIT;
