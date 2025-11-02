import React, { useEffect, useState, useContext } from 'react'
import { FaUserGraduate, FaSearch, FaSignOutAlt } from 'react-icons/fa'
import { useNavigate } from 'react-router-dom'
import { StudentAPI } from '../../api'
import { AuthContext } from '../../context/AuthContext' // ✅ ดึง context มาใช้
import 'bootstrap/dist/css/bootstrap.min.css'

export default function StudentDashboard() {
  const [exams, setExams] = useState([])
  const [filteredExams, setFilteredExams] = useState([])
  const [filters, setFilters] = useState({ exam: '', course: '', category: '', search: '' })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const { user, logout } = useContext(AuthContext) // ✅ ดึง user และ logout จาก context
  const token = user?.token
  const username = user?.username || 'Student' // ✅ ใช้ค่าจาก context
  const navigate = useNavigate()

  // โหลดข้อมูลจาก StudentAPI
  const loadExams = async () => {
    try {
      if (!token) return
      console.log('Loading exams with token:', token)
      const res = await StudentAPI.getDashboard(token)
      const data = res.data?.exams || []
      setExams(data)
      setFilteredExams(data)
    } catch (err) {
      console.error('Load exams failed:', err)
      setError('Cannot load exams.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { loadExams() }, [token]) // ✅ โหลดใหม่เมื่อ token เปลี่ยน

  const handleFilterChange = (key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }))
  }

  const applyFilter = () => {
    const filtered = exams.filter(e => {
      const matchExam = !filters.exam || e.ExamName?.toLowerCase().includes(filters.exam.toLowerCase())
      const matchCategory = !filters.category || e.CategoryName?.toLowerCase().includes(filters.category.toLowerCase())
      const matchCourse = !filters.course || e.CourseName?.toLowerCase().includes(filters.course.toLowerCase())
      const matchSearch =
        !filters.search ||
        e.ExamName?.toLowerCase().includes(filters.search.toLowerCase()) ||
        e.CourseName?.toLowerCase().includes(filters.search.toLowerCase()) ||
        e.TopicName?.toLowerCase().includes(filters.search.toLowerCase()) ||
        e.CategoryName?.toLowerCase().includes(filters.search.toLowerCase())

      return matchExam && matchCourse && matchCategory && matchSearch
    })
    setFilteredExams(filtered)
  }

  if (loading) return <div className="text-center mt-5">Loading exams...</div>
  if (error) return <div className="text-center text-danger mt-5">{error}</div>

  return (
    <div className="container py-4">
      {/* Header */}
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h1 className="fw-bold">
          Welcome Back <span className="text-primary">{username}</span>
        </h1>
        <div className="d-flex align-items-center gap-3">
          <button className="btn btn-outline-secondary" onClick={() => navigate('/student/profile')}>
            <FaUserGraduate className="me-2" /> Student Profile
          </button>
          <button className="btn btn-outline-danger" onClick={logout}>
            <FaSignOutAlt className="me-2" /> Logout
          </button>
        </div>
      </div>

      {/* Filter Section */}
      <div className="card p-3 mb-4 shadow-sm">
        <div className="row g-3 align-items-center">

          {/* Exam Name */}
          <div className="col-md-3">
            <label className="form-label">Exam</label>
            <input
              className="form-control"
              value={filters.exam}
              onChange={e => handleFilterChange('exam', e.target.value)}
              placeholder="Filter by exam"
            />
          </div>

          {/* Category Dropdown */}
          <div className="col-md-3">
            <label className="form-label">Category</label>
            <select
              className="form-select"
              value={filters.category}
              onChange={e => handleFilterChange('category', e.target.value)}
            >
              <option value="">All Categories</option>
              {[...new Set(exams.map(e => e.CategoryName).filter(Boolean))].map((cat, i) => (
                <option key={i} value={cat}>{cat}</option>
              ))}
            </select>
          </div>

          {/* Course Dropdown */}
          <div className="col-md-3">
            <label className="form-label">Course</label>
            <select
              className="form-select"
              value={filters.course}
              onChange={e => handleFilterChange('course', e.target.value)}
            >
              <option value="">All Courses</option>
              {[...new Set(exams.map(e => e.CourseName).filter(Boolean))].map((course, i) => (
                <option key={i} value={course}>{course}</option>
              ))}
            </select>
          </div>

          {/* Search bar */}
          <div className="col-md-3">
            <label className="form-label">Search</label>
            <div className="input-group">
              <input
                type="text"
                className="form-control"
                placeholder="Search anything..."
                value={filters.search}
                onChange={e => handleFilterChange('search', e.target.value)}
              />
              <button className="btn btn-outline-dark" onClick={applyFilter}>
                <FaSearch />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Table */}
      <table className="table table-bordered text-center align-middle shadow-sm">
        <thead className="table-dark">
          <tr>
            <th>Exam</th>
            <th>Category</th>
            <th>Course</th>
            <th>Topic</th>
            <th>Score</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {filteredExams.length > 0 ? (
            filteredExams.map((exam, index) => (
              <tr key={index}>
                <td className="fw-bold">{exam.ExamName}</td>
                <td>{exam.CategoryName || '-'}</td>
                <td>{exam.CourseName}</td>
                <td>{exam.TopicName}</td>
                <td>
                  {exam.Score > 0
                    ? `${exam.Score}/${exam.TotalPoints} (${exam.Percentage}%)`
                    : '-'}
                </td>
                <td>
                  <button
                    className="btn btn-dark btn-sm"
                    onClick={() => navigate(`/exam/${exam.ExamID}`)}
                  >
                    {exam.Score > 0 ? 'Retake' : 'Start'}
                  </button>
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="6" className="text-muted">No available exams.</td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  )
}
