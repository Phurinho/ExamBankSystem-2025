import React, { useContext } from 'react'
import { Navigate, Outlet } from 'react-router-dom'
import { AuthContext } from '../context/AuthContext.jsx'

export default function ProtectedRoute({ role }) {
  const { user } = useContext(AuthContext)

  // ถ้าไม่มี token ใน localStorage หรือ user ไม่มีค่า → กลับไปหน้า login
  const token = localStorage.getItem('token')
  if (!token || !user) {
    return <Navigate to="/" replace />
  }

  // ถ้ามี role แต่ไม่ตรงกับที่ต้องการ เช่น student ไปหน้า instructor → เด้งกลับ
  if (role && user.role !== role) {
    return <Navigate to="/" replace />
  }

  return <Outlet />
}
