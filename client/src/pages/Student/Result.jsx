import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { FaArrowLeft, FaCheckCircle, FaTimesCircle } from 'react-icons/fa'
import { StudentAPI } from '../../api'  // ✅ ใช้ API รวม

export default function Result() {
  const { id, attemptId } = useParams()
  const token = localStorage.getItem('token')
  const navigate = useNavigate()

  const [exam, setExam] = useState(null)
  const [attempt, setAttempt] = useState(null)
  const [questions, setQuestions] = useState([])
  const [loading, setLoading] = useState(true)

  // ✅ โหลดผลสอบ
  const loadResult = async () => {
    try {
      const res = await StudentAPI.getResult(id, attemptId, token)
      setExam(res.data.exam)
      setAttempt(res.data.attempt)
      setQuestions(res.data.questions)
    } catch (err) {
      console.error('❌ Load result failed:', err)
      alert(err.response?.data?.error || 'Failed to load result.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadResult()
  }, [id, attemptId])

  if (loading) return <div className="text-center mt-5">Loading result...</div>
  if (!exam || !attempt) return <div className="text-center text-danger mt-5">No result found.</div>

  return (
    <div className="container py-5" style={{ maxWidth: '900px' }}>
      {/* Header */}
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h2 className="fw-bold text-primary">{exam.ExamName}</h2>
        <button className="btn btn-outline-secondary" onClick={() => navigate(-1)}>
          <FaArrowLeft className="me-2" /> Back
        </button>
      </div>

      {/* Exam Info */}
      <div className="card shadow-sm border-0 mb-4">
        <div className="card-body">
          <p className="mb-1"><strong>Course:</strong> {exam.CourseName}</p>
          <p className="mb-1"><strong>Topic:</strong> {exam.TopicName}</p>
          <p className="mb-1">
            <strong>Submitted:</strong>{' '}
            {new Date(attempt.submitTime).toLocaleString()}
          </p>
          <h5 className="fw-bold mt-3 text-success">
            Score: {parseFloat(attempt.score || 0).toFixed(2)}/
            {parseFloat(attempt.totalPoints || 0).toFixed(2)} (
            {parseFloat(attempt.percentage || 0).toFixed(2)}%)
          </h5>
        </div>
      </div>

      {/* Questions */}
      {questions.map((q, idx) => {
        const isCorrect = q.StudentIsCorrect === 1
        return (
          <div
            key={q.QuestionID}
            className="card mb-4 border-0 shadow-sm"
            style={{
              borderLeft: `6px solid ${isCorrect ? '#198754' : '#dc3545'}`,
              borderRadius: '10px'
            }}
          >
            <div className="card-body">
              <div className="d-flex justify-content-between align-items-center mb-2">
                <h5 className="fw-bold mb-0">
                  Question {idx + 1}: {q.QuestionText}
                </h5>
                <span
                  className="badge bg-warning text-dark px-3 py-2 fw-semibold"
                  style={{ fontSize: '0.8rem' }}
                >
                  {q.LevelName} • {parseFloat(q.Points).toFixed(2)} pts
                </span>
              </div>

              {q.choices.map((choice, i) => {
                const studentPicked = q.StudentChoiceID === choice.ChoiceID
                const correctChoice = choice.IsCorrect === 1
                const textToShow =
                  q.TypeCode === 'TF'
                    ? choice.ChoiceText || (i === 0 ? 'True' : 'False')
                    : choice.ChoiceText

                return (
                  <div
                    key={choice.ChoiceID}
                    className={`p-2 rounded mb-1 ${
                      correctChoice
                        ? 'bg-success-subtle border border-success'
                        : studentPicked && !correctChoice
                        ? 'bg-danger-subtle border border-danger'
                        : 'bg-light'
                    }`}
                  >
                    <div className="form-check">
                      <input
                        type="radio"
                        className="form-check-input"
                        checked={studentPicked}
                        readOnly
                      />
                      <label className="form-check-label fw-semibold">
                        {choice.ChoiceNo}) {textToShow}
                      </label>
                      {correctChoice && <FaCheckCircle className="text-success ms-2" />}
                      {studentPicked && !correctChoice && <FaTimesCircle className="text-danger ms-2" />}
                    </div>
                  </div>
                )
              })}

              {/* Result per question */}
              <div className="mt-2 text-end">
                {isCorrect ? (
                  <span className="text-success fw-bold">+{q.PointsEarned} pts ✅</span>
                ) : (
                  <span className="text-danger fw-bold">0 pts ❌</span>
                )}
              </div>
            </div>
          </div>
        )
      })}

      {/* Back Button */}
      <div className="text-center mt-4">
        <button
          className="btn btn-primary px-5 py-2 fw-semibold"
          onClick={() => navigate('/student/dashboard')}
        >
          Back to Dashboard
        </button>
      </div>

      {/* Styles */}
      <style>{`
        .bg-success-subtle { background-color: #d1e7dd !important; }
        .bg-danger-subtle { background-color: #f8d7da !important; }
      `}</style>
    </div>
  )
}
