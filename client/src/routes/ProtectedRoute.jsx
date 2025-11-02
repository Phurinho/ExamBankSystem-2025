import React, { useContext } from 'react'
import { Navigate, Outlet } from 'react-router-dom'
import { AuthContext } from '../context/AuthContext.jsx'

export default function ProtectedRoute({ role }) {
  const { user } = useContext(AuthContext)
  const token = localStorage.getItem('token')

  // ❌ ถ้าไม่มี token หรือ user → กลับหน้า Login
  if (!token || !user) {
    return <Navigate to="/" replace />
  }

  // ✅ Logic role ยืดหยุ่น: ให้ admin เข้าหน้าที่ของ instructor ได้ด้วย
  const isAuthorized =
    !role ||                      // ถ้าไม่กำหนด role → เข้าได้หมด
    user.role === role ||         // role ตรงกันเป๊ะ
    (role === 'instructor' && user.role === 'admin') // admin เข้าหน้าที่ instructor ได้

  if (!isAuthorized) {
    return <Navigate to="/" replace />
  }

  // ✅ ผ่านทุกเงื่อนไข → แสดงหน้าได้
  return <Outlet />
}
