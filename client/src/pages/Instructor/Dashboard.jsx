import React, { useEffect, useState } from 'react'
import { FaEdit, FaTrash, FaEye, FaSearch, FaUndo } from 'react-icons/fa'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { InstructorAPI } from '../../api'   // ✅ ใช้ API รวมแทน axios

export default function InstructorDashboard() {
  const [exams, setExams] = useState([])
  const [filteredExams, setFilteredExams] = useState([])
  const [activeDropdown, setActiveDropdown] = useState(null)
 const [filters, setFilters] = useState({
  examName: '',
  courseName: '',
  topicName: '',
  categoryName: '',
  search: '',
  status: '',
});

  const token = localStorage.getItem('token')
  const navigate = useNavigate()

  // ✅ โหลดข้อสอบทั้งหมด
  const loadExams = async () => {
    try {
      const res = await InstructorAPI.getDashboard(token)
      setExams(res.data.exams || [])
      setFilteredExams(res.data.exams || [])
    } catch (err) {
      console.error('❌ Load exams failed:', err)
    }
  }

  // ✅ เปลี่ยนสถานะข้อสอบ
  const updateStatus = async (examId, newStatus) => {
    try {
      await InstructorAPI.updateExamStatus(examId, newStatus, token)
      setExams(prev =>
        prev.map(e =>
          e.ExamID === examId ? { ...e, Status: newStatus } : e
        )
      )
      setActiveDropdown(null)
    } catch (err) {
      console.error('❌ Status update failed:', err)
      alert('Failed to update status.')
    }
  }

  useEffect(() => { loadExams() }, [])

  // ✅ ฟิลเตอร์ client
useEffect(() => {
  let filtered = exams.filter(e => {
    const matchExam = !filters.examName || e.ExamName.toLowerCase().includes(filters.examName.toLowerCase());
    const matchCourse = !filters.courseName || e.CourseName.toLowerCase().includes(filters.courseName.toLowerCase());
    const matchTopic = !filters.topicName || e.TopicName.toLowerCase().includes(filters.topicName.toLowerCase());
    const matchCategory = !filters.categoryName || e.CategoryName === filters.categoryName;
    const matchStatus = !filters.status || e.Status === filters.status;
    return matchExam && matchCourse && matchTopic && matchCategory && matchStatus;
  });
  setFilteredExams(filtered);
}, [filters, exams]);

  const updateFilter = (key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }))
  }

  const resetFilters = () => {
    setFilters({
      examName: '',
      courseName: '',
      categoryName: '',
      search: '',
      status: '',
    })
    loadExams()
  }

  // ✅ ค้นหา backend อัตโนมัติ
  useEffect(() => {
    const delay = setTimeout(async () => {
      try {
        if (filters.search.trim() === '') {
          loadExams()
        } else {
          const res = await InstructorAPI.searchExams(filters.search, token)
          setExams(res.data.exams || [])
          setFilteredExams(res.data.exams || [])
        }
      } catch (err) {
        console.error('❌ Search failed:', err)
      }
    }, 400)
    return () => clearTimeout(delay)
  }, [filters.search])

 // ✅ ฟังก์ชันลบข้อสอบ
  const deleteExam = async (examId) => {
    if (!window.confirm('คุณแน่ใจหรือไม่ว่าต้องการลบข้อสอบนี้?')) return
    try {
      await InstructorAPI.deleteExam(examId, token)
      setExams(prev => prev.filter(e => e.ExamID !== examId))
      setFilteredExams(prev => prev.filter(e => e.ExamID !== examId))
      alert('🗑️ ลบข้อสอบเรียบร้อยแล้ว')
    } catch (err) {
      console.error('❌ Delete failed:', err)
      alert('ลบข้อสอบไม่สำเร็จ')
    }
  }

  // ===================== UI =====================
  return (
    <div className="container py-5">
      <h2 className="mb-4 fw-bold">📘 Instructor Dashboard</h2>

      {/* TODO: Filter bar (คงเดิม หรือเพิ่ม search input ก็ได้) */}
      {/* 🔍 Filter Bar */}
<div className="card p-3 mb-4 shadow-sm">
  <div className="row g-2 align-items-center">
    <div className="col-md-2">
      <input
        type="text"
        className="form-control"
        placeholder="Exam name..."
        value={filters.examName}
        onChange={(e) => updateFilter('examName', e.target.value)}
      />
    </div>
    <div className="col-md-2">
      <input
        type="text"
        className="form-control"
        placeholder="Course..."
        value={filters.courseName}
        onChange={(e) => updateFilter('courseName', e.target.value)}
      />
    </div>
    <div className="col-md-2">
      <input
        type="text"
        className="form-control"
        placeholder="Topic..."
        value={filters.topicName || ''}
        onChange={(e) => updateFilter('topicName', e.target.value)}
      />
    </div>
    <div className="col-md-2">
      <select
        className="form-select"
        value={filters.categoryName}
        onChange={(e) => updateFilter('categoryName', e.target.value)}
      >
        <option value="">All Categories</option>
        {[...new Set(exams.map(e => e.CategoryName).filter(Boolean))].map((cat, i) => (
          <option key={i} value={cat}>{cat}</option>
        ))}
      </select>
    </div>
    <div className="col-md-2">
      <select
        className="form-select"
        value={filters.status}
        onChange={(e) => updateFilter('status', e.target.value)}
      >
        <option value="">All Status</option>
        <option value="draft">Draft</option>
        <option value="published">Published</option>
      </select>
    </div>
    <div className="col-md-2 d-flex">
      <input
        type="text"
        className="form-control me-2"
        placeholder="Search..."
        value={filters.search}
        onChange={(e) => updateFilter('search', e.target.value)}
      />
      <button
        className="btn btn-outline-secondary"
        onClick={resetFilters}
        title="Reset"
      >
        <FaUndo />
      </button>
    </div>
  </div>
</div>

      <table className="table table-bordered text-center align-middle">
        <thead className="table-dark">
          <tr>
            <th>Exam</th>
            <th>Category</th>
            <th>Course</th>
            <th>Topic</th>
            <th>Status</th>
            <th>Control</th>
          </tr>
        </thead>
        <tbody>
          {filteredExams.length > 0 ? (
            filteredExams.map((exam, idx) => (
              <tr key={idx}>
                <td>{exam.ExamName}</td>
                <td>{exam.CategoryName || '-'}</td>
                <td>{exam.CourseName}</td>
                <td>{exam.TopicName}</td>

                {/* ✅ Animated Dropdown Status */}
                <td style={{ position: 'relative' }}>
                  <motion.span
                    className={`badge px-3 py-2 fw-semibold ${
                      exam.Status === 'published'
                        ? 'bg-success'
                        : 'bg-warning text-dark'
                    }`}
                    style={{ cursor: 'pointer' }}
                    whileHover={{ scale: 1.05 }}
                    onClick={() =>
                      setActiveDropdown(
                        activeDropdown === exam.ExamID ? null : exam.ExamID
                      )
                    }
                  >
                    {exam.Status}
                  </motion.span>

                  <AnimatePresence>
                    {activeDropdown === exam.ExamID && (
                      <motion.div
                        key="dropdown"
                        initial={{ opacity: 0, y: -5 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -5 }}
                        transition={{ duration: 0.2 }}
                        className="dropdown-menu show mt-2 shadow-sm"
                        style={{
                          display: 'block',
                          position: 'absolute',
                          zIndex: 10,
                          left: '50%',
                          transform: 'translateX(-50%)',
                        }}
                      >
                        {['draft', 'published']
                          .filter(s => s !== exam.Status)
                          .map((status, i) => (
                            <button
                              key={i}
                              className={`dropdown-item text-center fw-semibold text-${
                                status === 'published' ? 'success' : 'warning'
                              }`}
                              onClick={() => updateStatus(exam.ExamID, status)}
                            >
                              {status}
                            </button>
                          ))}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </td>

                <td>
                  <button
                    className="btn btn-sm btn-outline-secondary me-2"
                    onClick={() => navigate(`/instructor/exam/${exam.ExamID}`)}
                  >
                    <FaEye /> View
                  </button>
                  <button
                    className="btn btn-sm btn-outline-primary me-2"
                    onClick={() => navigate(`/instructor/exam/${exam.ExamID}/edit`)}
                  >
                    <FaEdit /> Edit
                  </button>
                  <button
                    className="btn btn-sm btn-outline-danger"
                    onClick={() => deleteExam(exam.ExamID)}
                  >
                    <FaTrash />
                  </button>
                </td>
              </tr>
            ))
          ) : (
            <tr>
              <td colSpan="6" className="text-muted">
                No exams found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  )
}
