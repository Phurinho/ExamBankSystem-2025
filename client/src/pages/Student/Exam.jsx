import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { FaArrowLeft } from 'react-icons/fa'
import { StudentAPI } from '../../api'  // ✅ import API รวม

export default function Exam() {
  const { id } = useParams()
  const navigate = useNavigate()
  const token = localStorage.getItem('token')

  const [exam, setExam] = useState(null)
  const [questions, setQuestions] = useState([])
  const [answers, setAnswers] = useState({})
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [showResult, setShowResult] = useState(false)
  const [result, setResult] = useState({ score: 0, totalPoints: 0, percentage: 0 })

  // ✅ โหลดข้อสอบ
  const loadExam = async () => {
    try {
      const res = await StudentAPI.getExam(id, token)
      setExam(res.data.exam)
      setQuestions(res.data.questions)
    } catch (err) {
      console.error('❌ Load exam failed:', err)
      alert(err.response?.data?.error || 'Failed to load exam.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadExam()
  }, [id])

  // ✅ เก็บคำตอบ
  const handleAnswer = (questionId, choiceId) => {
    setAnswers((prev) => ({ ...prev, [questionId]: choiceId }))
  }

  // ✅ ส่งคำตอบทั้งหมด
  const handleSubmitExam = async () => {
    if (Object.keys(answers).length !== questions.length) {
      alert('Please answer all questions before submitting.')
      return
    }

    const formattedAnswers = Object.entries(answers).map(([questionId, choiceId]) => ({
      questionId: Number(questionId),
      choiceId: Number(choiceId),
    }))

    setSubmitting(true)
    try {
      const res = await StudentAPI.submitExam(id, formattedAnswers, token)
      setResult({
        attemptId: res.data.attemptId,
        score: res.data.score,
        totalPoints: res.data.totalPoints,
        percentage: res.data.percentage,
      })
      setShowResult(true)
    } catch (err) {
      console.error('❌ Submit failed:', err.response?.data || err)
      alert(err.response?.data?.error || 'Failed to submit exam.')
    } finally {
      setSubmitting(false)
    }
  }

  if (loading) return <div className="text-center mt-5">Loading exam...</div>
  if (!exam) return <div className="text-center text-danger mt-5">Exam not found.</div>

  // ✅ UI
  return (
    <div className="container py-5">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h3 className="fw-bold text-primary mb-0">{exam.ExamName}</h3>
        <button className="btn btn-outline-secondary" onClick={() => navigate('/student/dashboard')}>
          <FaArrowLeft className="me-2" /> Back
        </button>
      </div>

      <p className="text-muted">
        <strong>Category:</strong> {exam.CategoryName || '-'} |{' '}
        <strong>Course:</strong> {exam.CourseName} |{' '}
        <strong>Topic:</strong> {exam.TopicName}
      </p>

      {questions.map((q, idx) => (
        <div
          key={q.QuestionID}
          className="card p-4 mb-4 shadow-sm border-0"
          style={{ borderLeft: '6px solid #0d6efd', borderRadius: '12px' }}
        >
          <div className="d-flex justify-content-between align-items-center mb-2">
            <h5 className="mb-0">
              Question {idx + 1}: {q.QuestionText}
            </h5>
            <span
              className="px-3 py-1 rounded-pill fw-semibold"
              style={{
                background:
                  q.LevelName === 'Easy'
                    ? 'linear-gradient(90deg, #b2f2bb, #69db7c)'
                    : q.LevelName === 'Medium'
                    ? 'linear-gradient(90deg, #ffe066, #fab005)'
                    : 'linear-gradient(90deg, #ff6b6b, #fa5252)',
                color: '#222',
                fontSize: '0.8rem',
              }}
            >
              {q.LevelName} • {parseFloat(q.Points).toFixed(2)} pts
            </span>
          </div>

          {q.TypeCode === 'MCQ' &&
            q.choices.map((choice) => (
              <div key={choice.ChoiceID} className="form-check my-1">
                <input
                  type="radio"
                  name={`q_${q.QuestionID}`}
                  className="form-check-input"
                  checked={answers[q.QuestionID] === choice.ChoiceID}
                  onChange={() => handleAnswer(q.QuestionID, choice.ChoiceID)}
                />
                <label className="form-check-label">
                  <strong>{choice.ChoiceNo})</strong> {choice.ChoiceText}
                </label>
              </div>
            ))}

          {q.TypeCode === 'TF' &&
            q.choices.map((choice, i) => (
              <div key={choice.ChoiceID} className="form-check my-1">
                <input
                  type="radio"
                  className="form-check-input"
                  name={`q_${q.QuestionID}`}
                  checked={answers[q.QuestionID] === choice.ChoiceID}
                  onChange={() => handleAnswer(q.QuestionID, choice.ChoiceID)}
                />
                <label className="form-check-label">
                  {choice.ChoiceText || (i === 0 ? 'True' : 'False')}
                </label>
              </div>
            ))}
        </div>
      ))}

      <div className="text-center mt-4">
        <button
          className="btn btn-primary px-5 py-2 rounded-3 fw-semibold"
          disabled={submitting}
          onClick={handleSubmitExam}
        >
          {submitting ? 'Submitting...' : 'Submit Exam'}
        </button>
      </div>

      {showResult && (
        <div className="modal show fade d-block" tabIndex="-1">
          <div className="modal-dialog modal-dialog-centered">
            <div
              className="modal-content text-center p-5 text-white rounded-4 shadow-lg"
              style={{ background: 'linear-gradient(135deg, #212529, #343a40, #495057)' }}
            >
              <h4 className="mb-3 fw-bold">
                Score: {result.score}/{result.totalPoints}
              </h4>
              <h5 className="mb-4">Percentage: {result.percentage}%</h5>

              <div className="d-flex justify-content-center gap-3">
                <button
                  className="btn btn-outline-light px-4"
                  onClick={() =>
                    navigate(`/student/exam/${id}/result/${result.attemptId}`)
                  }
                >
                  Show Answer
                </button>

                <button
                  className="btn btn-light text-dark px-4"
                  onClick={() => window.location.reload()}
                >
                  Try Again
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      <style>{`
        .modal-content { animation: popIn 0.35s ease-in-out; }
        @keyframes popIn {
          from { transform: scale(0.9); opacity: 0; }
          to { transform: scale(1); opacity: 1; }
        }
      `}</style>
    </div>
  )
}
