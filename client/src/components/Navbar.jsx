import React, { useContext } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { AuthContext } from '../context/AuthContext.jsx'

export default function Navbar() {
  const { user, logout } = useContext(AuthContext)
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/') // กลับหน้า Login หลัง logout
  }

  return (
    <nav className="navbar navbar-expand-lg bg-light border-bottom">
      <div className="container">
        <Link className="navbar-brand fw-bold" to="/">OnlineExam</Link>

        <div className="collapse navbar-collapse">
          <ul className="navbar-nav ms-auto">
            {!user ? (
              // ถ้ายังไม่ได้ login
              <li className="nav-item">
                <Link className="nav-link" to="/">Login</Link>
              </li>
            ) : (
              // ถ้า login แล้ว
              <>
                <li className="nav-item me-3">
                  <span className="nav-link">Hi, {user.username || 'User'}</span>
                </li>
                <li className="nav-item">
                  <button
                    className="btn btn-outline-dark btn-sm"
                    onClick={logout}
                  >
                    Logout
                  </button>
                </li>
              </>
            )}
          </ul>
        </div>
      </div>
    </nav>
  )
}
