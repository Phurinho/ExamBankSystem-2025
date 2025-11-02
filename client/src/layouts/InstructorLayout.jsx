import React from 'react'
import { Outlet, Link, useNavigate } from 'react-router-dom'

export default function InstructorLayout() {
  const navigate = useNavigate()

  const handleLogout = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('role')
    navigate('/')
  }

  return (
    <div className="d-flex" style={{ minHeight: '100vh' }}>
      {/* Sidebar */}
      <div className="bg-dark text-white p-3" style={{ width: '240px' }}>
        <h4 className="mb-4 text-center">Instructor Panel</h4>
        <ul className="nav flex-column">
          <li className="nav-item mb-2">
            <Link className="nav-link text-white" to="/instructor/dashboard">📋 Dashboard</Link>
          </li>
          <li className="nav-item mb-2">
            <Link className="nav-link text-white" to="/instructor/create">🧩 Create Exam</Link>
          </li>
          <li className="nav-item mb-2">
            <Link className="nav-link text-white" to="/instructor/profile">👤 Profile</Link>
          </li>
          <li className="nav-item mt-4">
            <button className="btn btn-danger w-100" onClick={handleLogout}>Logout</button>
          </li>
        </ul>
      </div>

      {/* Main Content */}
      <div className="flex-grow-1 bg-light p-4">
        <Outlet />
      </div>
    </div>
  )
}
