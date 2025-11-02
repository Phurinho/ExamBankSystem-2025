# 1. ติดตั้ง
npm install bcrypt bcryptjs cors dotenv express express-rate-limit helmet jsonwebtoken morgan mysql2

# 2. (ทางเลือก) ติด nodemon สำหรับ dev
npm install --save-dev nodemon


.env structure in backend
PORT=3000
DB_HOST=127.0.0.1
DB_USER=root
DB_PASSWORD=your_pass
DB_NAME=

JWT_SECRET= node -e "console.log(require('crypto').randomBytes(32).toString('base64'))" ลองรัน
