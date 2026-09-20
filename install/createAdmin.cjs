require('dotenv').config({ path: `${__dirname}/../.env` });
const { Client } = require('pg');
const bcrypt = require('bcrypt');

// Создаёт (или повышает до admin существующего) пользователя.
// Использование: node install/createAdmin.cjs <email> <password> [name]
const [, , email, password, name] = process.argv;

if (!email || !password) {
  console.error('Usage: node install/createAdmin.cjs <email> <password> [name]');
  process.exit(1);
}

(async function run() {
  const client = new Client({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASS,
    port: process.env.DB_PORT,
  });

  try {
    await client.connect();
    const hash = bcrypt.hashSync(password, 10);

    const result = await client.query(
      `INSERT INTO my_user (email, password, role, name, active)
       VALUES ($1, $2, 'admin', $3, true)
       ON CONFLICT (email) DO UPDATE
         SET password = EXCLUDED.password,
             role = 'admin',
             active = true
       RETURNING id, email, role`,
      [email.toLowerCase(), hash, name || 'Admin']
    );

    console.log('SUCCESS', result.rows[0]);
  } catch (e) {
    console.error('ERROR', e.stack);
  } finally {
    await client.end();
  }
})();
