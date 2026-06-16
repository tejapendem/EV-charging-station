import pkg from 'pg';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pkg;
const __dirname = path.dirname(fileURLToPath(import.meta.url));

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 5432,
  database: process.env.DB_NAME || 'ev_connect_india',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle database client', err);
  process.exit(-1);
});

pool.on('connect', () => {
  console.log('New client connected to PostgreSQL');
});

export const query = (text, params) => pool.query(text, params);

export const getClient = () => pool.connect();

export const runMigrations = async () => {
  const migrationsDir = path.join(__dirname, '../../migrations');
  const files = fs.readdirSync(migrationsDir).filter((f) => f.endsWith('.sql')).sort();

  for (const file of files) {
    const filePath = path.join(migrationsDir, file);
    const sql = fs.readFileSync(filePath, 'utf-8');
    try {
      await query(sql);
      console.log(`Migration ${file} executed successfully`);
    } catch (error) {
      console.error(`Migration ${file} failed:`, error.message);
      throw error;
    }
  }
};

if (process.argv.includes('--migrate')) {
  (async () => {
    try {
      await runMigrations();
      console.log('All migrations completed');
      process.exit(0);
    } catch (error) {
      console.error('Migration failed:', error);
      process.exit(1);
    }
  })();
}

if (process.argv.includes('--seed')) {
  (async () => {
    try {
      const seedPath = path.join(__dirname, '../../migrations/002_seed_data.sql');
      const seedSql = fs.readFileSync(seedPath, 'utf-8');
      await query(seedSql);
      console.log('Seed data inserted successfully');
      process.exit(0);
    } catch (error) {
      console.error('Seeding failed:', error);
      process.exit(1);
    }
  })();
}

export default pool;
