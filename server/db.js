const mysql = require('mysql2/promise');
require('dotenv').config();

let db;

try {
  db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || '',
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    connectTimeout: 20000, // ⏱ ป้องกัน timeout ตอนเชื่อม Railway
  });

  // ✅ ทดสอบการเชื่อมต่อ (เฉพาะตอนเริ่มเซิร์ฟเวอร์)
  db.query('SELECT 1')
    .then(() => console.log('✅ MySQL Connected Successfully!'))
    .catch((err) => {
      console.error('❌ Database connection failed:', err.message);
      console.error('🔍 ตรวจสอบค่าจาก .env หรือสถานะ Railway DB อีกครั้ง');
    });

} catch (err) {
  console.error('🚨 MySQL Pool Initialization Error:', err.message);
}

module.exports = db;
