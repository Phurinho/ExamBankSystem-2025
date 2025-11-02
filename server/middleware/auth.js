const jwt = require('jsonwebtoken');
require('dotenv').config();

// ฟังก์ชันตรวจสอบ Token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'ไม่มี token' });  // เพิ่ม return
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'token ไม่ถูกต้องหรือหมดอายุ' });  // เพิ่ม return
    }
    
    req.user = user;
    next();
  });
}

function requireInstructor(req, res, next) {
  // ✅ อนุญาต instructor และ admin
  if (req.user.role !== 'instructor' && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'ต้องเป็น instructor หรือ admin เท่านั้น' });
  }
  next();
}



function requireStudent(req, res, next) {
  if (req.user.role !== 'student') {
    return res.status(403).json({ error: 'ต้องเป็น student เท่านั้น' });
  }
  next();
}

module.exports = { 
  authenticateToken, 
  requireInstructor,
  requireStudent,
  
};
