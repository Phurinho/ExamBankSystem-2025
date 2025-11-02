import React from 'react'
import { Outlet } from 'react-router-dom'
import Navbar from '../components/Navbar.jsx'

export default function MainLayout() {
  return (
    <>
      <Navbar />
      <div className="container my-4">
        <Outlet />
      </div>
    </>
  )
}
