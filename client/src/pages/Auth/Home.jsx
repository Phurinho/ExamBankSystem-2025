import React, { useState, useEffect } from 'react'
import { ROLES } from '../../utils/constants'
import Modal from 'react-bootstrap/Modal'
import 'bootstrap/dist/css/bootstrap.min.css'
import { useNavigate } from 'react-router'
import Swal from 'sweetalert2'
import { AuthAPI } from '../../api' // ✅ import จาก api.js

export default function Home() {
  const navigate = useNavigate()
  const [loginData, setLoginData] = useState({ username: '', password: '' })
  const [registerData, setRegisterData] = useState({
    username: '',
    email: '',
    password: '',
    department: '',
    role: ROLES.STUDENT,
    studentId: '',
  })
  const [showRegister, setShowRegister] = useState(false)

  // ✅ handle input change
  const handleLoginChange = (e) => {
    const { name, value } = e.target
    setLoginData(prev => ({ ...prev, [name]: value }))
  }

  const handleRegisterChange = (e) => {
    const { name, value } = e.target
    setRegisterData(prev => ({ ...prev, [name]: value }))
  }

  const handleRoleChange = (role) => {
    setRegisterData(prev => ({
      ...prev,
      role,
      studentId: role === ROLES.STUDENT ? prev.studentId : ''
    }))
  }

  // ✅ Login
  const handleLoginSubmit = async (e) => {
    e.preventDefault()

    try {
      const res = await AuthAPI.login({
        username: loginData.username.trim(),
        password: loginData.password.trim()
      })

      const data = res.data
      console.log('✅ Login success:', data)

      const role = data.user.role || data.user.Role
      const username = data.user.username || data.user.Username
      const token = data.token

      // เก็บ token และข้อมูลผู้ใช้
      localStorage.setItem('token', token)
      localStorage.setItem('role', role)
      localStorage.setItem('username', username)

      Swal.fire({
        icon: 'success',
        title: 'Login Successful!',
        text: `Welcome back, ${username}!`,
        timer: 1500,
        showConfirmButton: false
      })

      // redirect
      setTimeout(() => {
        if (role === 'instructor' || role === 'admin') {
  navigate('/instructor/dashboard')
} else if (role === 'student') {
  navigate('/student/dashboard')
} else {
  Swal.fire('Unknown role', '', 'error')
}

      }, 1500)
    } catch (err) {
      console.error('❌ Login error:', err)
      Swal.fire({
        icon: 'error',
        title: 'Login Failed',
        text: err.response?.data?.error || 'Invalid credentials or server issue.',
        confirmButtonColor: '#d33'
      })
    }
  }

  // ✅ Register
  const handleRegisterSubmit = async (e) => {
    e.preventDefault()
    try {
      const res = await AuthAPI.register(registerData)
      console.log('✅ Register success:', res.data)

      Swal.fire({
        icon: 'success',
        title: 'Register Successfully!',
        text: 'Your account has been created 🎉',
        confirmButtonColor: '#3085d6'
      })

      setShowRegister(false)
      setRegisterData({
        username: '',
        email: '',
        password: '',
        department: '',
        role: ROLES.STUDENT,
        studentId: '',
      })
    } catch (err) {
      console.error('❌ Register error:', err)
      Swal.fire({
        icon: 'error',
        title: 'Register Failed',
        text: err.response?.data?.error || 'Unable to register. Please try again.',
        confirmButtonColor: '#d33'
      })
    }
  }

  // ✅ ถ้ามี token อยู่แล้ว -> redirect ทันที
  useEffect(() => {
    const token = localStorage.getItem('token')
    const role = localStorage.getItem('role')

    if (token && role) {
      if (role === 'student') navigate('/student/dashboard', { replace: true })
      if (role === 'instructor') navigate('/instructor/dashboard', { replace: true })
      if (role === 'admin') navigate('/instructor/dashboard', { replace: true })
    }
  }, [navigate])

  return (
    <div className="bg-light min-vh-100 d-flex flex-column justify-content-start align-items-center pt-5">
      <h1 className="fw-bold mb-4 text-center mt-3">Welcome to Online Exam Web page</h1>

      {/* Login Form */}
      <form className="p-4 bg-white rounded shadow-sm" style={{ width: '320px' }} onSubmit={handleLoginSubmit}>
        <h5 className="text-center mb-3">Login</h5>
        <div className="mb-3">
          <label className="form-label">Username</label>
          <input
            className="form-control"
            type="text"
            name="username"
            value={loginData.username}
            onChange={handleLoginChange}
            required
            autoComplete="username"
          />
        </div>
        <div className="mb-3">
          <label className="form-label">Password</label>
          <input
            className="form-control"
            type="password"
            name="password"
            value={loginData.password}
            onChange={handleLoginChange}
            required
            autoComplete="current-password"
          />
        </div>
        <div className="text-center mb-3">
          <small className="text-muted">
            Don't have an account?{' '}
            <span role="button" className="text-primary" onClick={() => setShowRegister(true)}>
              Register here
            </span>
          </small>
        </div>
        <button className="btn btn-dark w-100" type="submit">Login</button>
      </form>

      {/* Register Modal */}
      <Modal show={showRegister} onHide={() => setShowRegister(false)} centered>
        <Modal.Header closeButton>
          <Modal.Title>Register</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <form onSubmit={handleRegisterSubmit}>
            <div className="mb-2">
              <label className="form-label">Username</label>
              <input className="form-control" name="username" value={registerData.username} onChange={handleRegisterChange} required autoComplete="username" />
            </div>
            <div className="mb-2">
              <label className="form-label">Email Address</label>
              <input type="email" className="form-control" name="email" value={registerData.email} onChange={handleRegisterChange} required autoComplete="email" />
            </div>
            <div className="mb-2">
              <label className="form-label">Password</label>
              <input type="password" className="form-control" name="password" value={registerData.password} onChange={handleRegisterChange} required autoComplete="new-password" />
            </div>
            <div className="mb-2">
              <label className="form-label">Department</label>
              <input className="form-control" name="department" value={registerData.department} onChange={handleRegisterChange} />
            </div>
            <div className="mb-2">
              <label className="form-label d-block">Role</label>
              <div className="btn-group w-100">
                <button
                  type="button"
                  className={`btn ${registerData.role === ROLES.STUDENT ? 'btn-secondary' : 'btn-outline-secondary'}`}
                  onClick={() => handleRoleChange(ROLES.STUDENT)}>
                  Student
                </button>
                <button
                  type="button"
                  className={`btn ${registerData.role === ROLES.INSTRUCTOR ? 'btn-secondary' : 'btn-outline-secondary'}`}
                  onClick={() => handleRoleChange(ROLES.INSTRUCTOR)}>
                  Instructor
                </button>
              </div>
            </div>
            {registerData.role === ROLES.STUDENT && (
              <div className="mb-2">
                <label className="form-label">Student ID</label>
                <input className="form-control" name="studentId" value={registerData.studentId} onChange={handleRegisterChange} required />
              </div>
            )}
            <button className="btn btn-dark w-100 mt-3" type="submit">Register</button>
          </form>
        </Modal.Body>
      </Modal>
    </div>
  )
}
