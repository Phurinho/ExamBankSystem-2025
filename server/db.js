const mysql = require('mysql2/promise');
require('dotenv').config();

const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  connectTimeout: 20000, // เพิ่ม timeout กันหลุด
});

db.query('SELECT 1')
  .then(() => console.log('✅ เชื่อมต่อ Database สำเร็จ'))
  .catch(err => console.error('❌ MySQL connection error:', err.message));

module.exports = db;
