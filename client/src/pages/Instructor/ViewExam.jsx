import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { FaArrowLeft, FaCheckCircle } from 'react-icons/fa'
import { InstructorAPI } from '../../api'  // ✅ ใช้ InstructorAPI จาก api.js

export default function ViewExam() {
  const { id } = useParams()
  const navigate = useNavigate()
  const token = localStorage.getItem('token')

  const [exam, setExam] = useState(null)
  const [questions, setQuestions] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  // ✅ โหลดข้อมูลจาก backend
  const loadExam = async () => {
    try {
      const res = await InstructorAPI.getExamById(id, token)
      setExam(res.data.exam)
      setQuestions(res.data.questions)
    } catch (err) {
      console.error('❌ Error loading exam:', err)
      setError(err.response?.data?.error || 'Failed to load exam data.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { loadExam() }, [id])

  // ✅ Loading / Error / Not Found
  if (loading) return <div className="text-center mt-5">Loading...</div>
  if (error) return <div className="text-center text-danger mt-5">{error}</div>
  if (!exam) return <div className="text-center mt-5">Exam not found.</div>

  // ✅ UI
  return (
    <div className="container py-5">
      {/* Header */}
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h2 className="fw-bold text-primary mb-0">Exam Detail</h2>
        <button className="btn btn-outline-secondary" onClick={() => navigate(-1)}>
          <FaArrowLeft className="me-2" /> Back
        </button>
      </div>

      {/* Exam Info */}
      <div className="card p-3 mb-4 shadow-sm">
        <div className="row">
          <div className="col-md-6">
            <p><strong>Exam Name:</strong> {exam.ExamName}</p>
            <p><strong>Course:</strong> {exam.CourseName} ({exam.CourseCode})</p>
            <p><strong>Category:</strong> {exam.CategoryName || '-'}</p>
          </div>
          <div className="col-md-6">
            <p><strong>Topic:</strong> {exam.TopicName}</p>
            <p>
              <strong>Status:</strong>{' '}
              <span
                className={`badge ${
                  exam.Status === 'published'
                    ? 'bg-success'
                    : 'bg-warning text-dark'
                }`}
              >
                {exam.Status}
              </span>
            </p>
          </div>
        </div>
      </div>

      {/* Questions */}
      <h4 className="fw-bold mb-3">Questions ({questions.length})</h4>

      {questions.map((q, index) => (
        <div key={q.QuestionID} className="card mb-3 shadow-sm">
          <div className="card-header bg-light">
            <strong>Question {index + 1}:</strong> {q.QuestionText}
          </div>

          <div className="card-body">
            <p><strong>Type:</strong> {q.TypeName}</p>
            <p><strong>Difficulty:</strong> {q.LevelName}</p>
            <p><strong>Points:</strong> {q.Points}</p>

            {/* ✅ แสดงตัวเลือก */}
            {q.choices && q.choices.length > 0 ? (
              <ul className="list-group">
                {q.choices.map((choice, i) => (
                  <li
                    key={choice.ChoiceID}
                    className={`list-group-item d-flex justify-content-between align-items-center ${
                      choice.IsCorrect ? 'list-group-item-success' : ''
                    }`}
                  >
                    <span>
                      <strong>{String.fromCharCode(65 + i)}.</strong>{' '}
                      {q.TypeCode === 'TF'
                        ? i === 0
                          ? choice.ChoiceText || 'True'
                          : choice.ChoiceText || 'False'
                        : choice.ChoiceText}
                    </span>
                    {choice.IsCorrect && <FaCheckCircle className="text-success" />}
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-muted fst-italic">No choices available.</p>
            )}
          </div>
        </div>
      ))}

      {questions.length === 0 && (
        <div className="alert alert-warning text-center mt-3">
          No questions found for this exam.
        </div>
      )}
    </div>
  )
}
