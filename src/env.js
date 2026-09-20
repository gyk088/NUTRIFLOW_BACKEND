// Must be the very first import in src/index.js — ESM import statements are
// hoisted and fully evaluated in file order, so any module imported before
// this one would see process.env.* as unset (e.g. AuthService.js computes
// GOOGLE_AUDIENCES from env vars at module load time, not inside a function).
import dotenv from 'dotenv';
dotenv.config();
