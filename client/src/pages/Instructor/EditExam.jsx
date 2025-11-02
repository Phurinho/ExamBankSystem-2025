import React, { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { FaArrowLeft, FaPlus, FaTrash, FaChevronUp, FaChevronDown, FaSave } from 'react-icons/fa'
import { InstructorAPI } from '../../api'  // ✅ ใช้ InstructorAPI จาก api.js

export default function EditExam() {
  const { id } = useParams()
  const navigate = useNavigate()
  const token = localStorage.getItem('token')

  const [examMeta, setExamMeta] = useState({
    examName: '',
    course: '',
    topic: '',
    category: ''
  })
  const [questions, setQuestions] = useState([])
  const [activeQuestion, setActiveQuestion] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)

  // ✅ โหลดข้อมูลข้อสอบเดิม
  const loadExam = async () => {
    try {
      const res = await InstructorAPI.getExamById(id, token)
      const data = res.data

      setExamMeta({
        examName: data.exam.ExamName,
        course: data.exam.CourseName,
        topic: data.exam.TopicName,
        category: data.exam.CategoryName
      })

      // แปลง questions ให้อยู่ในรูปแบบเดียวกับ CreateExam
      const transformed = data.questions.map(q => ({
        id: q.QuestionID,
        type: q.TypeCode === 'TF' ? 'TrueFalse' : 'MCQ',
        difficulty: q.LevelCode,
        questionText: q.QuestionText,
        points: q.Points,
        choices: q.choices.map(c => ({
          text: c.ChoiceText,
          isCorrect: c.IsCorrect === 1
        }))
      }))
      setQuestions(transformed)
    } catch (err) {
      console.error('❌ Load exam failed:', err)
      alert(err.response?.data?.error || 'Failed to load exam data.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { loadExam() }, [id])

  // ✅ เพิ่มคำถามใหม่
  const addQuestion = () => {
    const newQ = {
      id: Date.now(),
      type: 'MCQ',
      difficulty: 'EASY',
      questionText: '',
      points: 1,
      choices: [
        { text: '', isCorrect: false },
        { text: '', isCorrect: false }
      ]
    }
    setQuestions(prev => [...prev, newQ])
    setActiveQuestion(newQ.id)
  }

  // ✅ ลบคำถาม
  const deleteQuestion = id => setQuestions(prev => prev.filter(q => q.id !== id))

  // ✅ อัปเดตข้อมูลคำถาม
  const updateQuestion = (id, key, value) => {
    setQuestions(prev => prev.map(q => (q.id === id ? { ...q, [key]: value } : q)))
  }

  // ✅ เพิ่ม / ลบตัวเลือก
  const addChoice = id => {
    setQuestions(prev =>
      prev.map(q =>
        q.id === id
          ? { ...q, choices: [...q.choices, { text: '', isCorrect: false }] }
          : q
      )
    )
  }

  const deleteChoice = (qid, idx) => {
    setQuestions(prev =>
      prev.map(q =>
        q.id === qid
          ? { ...q, choices: q.choices.filter((_, i) => i !== idx) }
          : q
      )
    )
  }

  // ✅ toggle ติ๊กคำตอบถูกต้อง
  const toggleCorrectChoice = (qid, idx) => {
    setQuestions(prev =>
      prev.map(q => {
        if (q.id === qid) {
          const newChoices = q.choices.map((c, i) => ({
            ...c,
            isCorrect: i === idx
          }))
          return { ...q, choices: newChoices }
        }
        return q
      })
    )
  }

  // ✅ toggle collapse
  const toggleQuestion = id => setActiveQuestion(activeQuestion === id ? null : id)

  // ✅ บันทึกข้อมูลข้อสอบ
  const handleSave = async () => {
    setSaving(true)
    try {
      const payload = {
        examName: examMeta.examName,
        courseName: examMeta.course,
        courseCode: examMeta.course, // รองรับ backend ที่ใช้ชื่อ courseCode
        topicName: examMeta.topic,
        categoryName: examMeta.category,
        status: 'draft',
        questions: questions.map(q => ({
          questionText: q.questionText,
          typeCode: q.type === 'TrueFalse' ? 'TF' : 'MCQ',
          difficulty: q.difficulty,
          points: Number(q.points) || 1,
          choices: q.choices.map(c => ({
            text: c.text,
            isCorrect: c.isCorrect
          }))
        }))
      }

      const res = await InstructorAPI.updateExam(id, payload, token)

      if (res.status === 200) {
        alert('✅ Exam updated successfully!')
        navigate('/instructor/dashboard')
      } else {
        alert('⚠️ Failed to update exam.')
      }
    } catch (err) {
      console.error('❌ Save failed:', err)
      alert(err.response?.data?.error || 'Failed to save exam. Check console for details.')
    } finally {
      setSaving(false)
    }
  }

  if (loading) return <div className="text-center mt-5">Loading...</div>

  // ✅ UI
  return (
    <div className="container py-4">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h2 className="fw-bold text-primary">Edit Exam</h2>
        <button className="btn btn-outline-secondary" onClick={() => navigate(-1)}>
          <FaArrowLeft className="me-2" /> Back
        </button>
      </div>

      {/* Exam Info */}
      <div className="card p-3 mb-4">
        <h5 className="fw-bold mb-3">Exam Info</h5>
        <div className="row g-3">
          <div className="col-md-3">
            <label className="form-label">Exam Name</label>
            <input
              className="form-control"
              value={examMeta.examName}
              onChange={e => setExamMeta({ ...examMeta, examName: e.target.value })}
            />
          </div>
          <div className="col-md-3">
            <label className="form-label">Course</label>
            <input
              className="form-control"
              value={examMeta.course}
              onChange={e => setExamMeta({ ...examMeta, course: e.target.value })}
            />
          </div>
          <div className="col-md-3">
            <label className="form-label">Topic</label>
            <input
              className="form-control"
              value={examMeta.topic}
              onChange={e => setExamMeta({ ...examMeta, topic: e.target.value })}
            />
          </div>
          <div className="col-md-3">
            <label className="form-label">Category</label>
            <input
              className="form-control"
              value={examMeta.category}
              onChange={e => setExamMeta({ ...examMeta, category: e.target.value })}
              placeholder="e.g. Computer Science"
            />
          </div>
        </div>
      </div>

      {/* Questions */}
      <div className="mb-4">
        <div className="d-flex justify-content-between align-items-center mb-3">
          <h5 className="fw-bold">Questions ({questions.length})</h5>
          <button className="btn btn-sm btn-dark" onClick={addQuestion}>
            <FaPlus className="me-1" /> Add Question
          </button>
        </div>

        {questions.map((q, idx) => (
          <div key={q.id} className="card p-3 mb-3 shadow-sm">
            <div className="d-flex justify-content-between align-items-center mb-2">
              <h6 className="mb-0">Question {idx + 1}</h6>
              <div>
                <button
                  className="btn btn-sm btn-outline-secondary me-2"
                  onClick={() => toggleQuestion(q.id)}
                >
                  {activeQuestion === q.id ? <FaChevronUp /> : <FaChevronDown />}
                </button>
                <button
                  className="btn btn-sm btn-outline-danger"
                  onClick={() => deleteQuestion(q.id)}
                >
                  <FaTrash />
                </button>
              </div>
            </div>

            {activeQuestion === q.id && (
              <>
                <div className="row g-2 mb-2">
                  <div className="col-md-4">
                    <label className="form-label">Type</label>
                    <select
                      className="form-select"
                      value={q.type}
                      onChange={e => updateQuestion(q.id, 'type', e.target.value)}
                    >
                      <option value="MCQ">MCQ</option>
                      <option value="TrueFalse">True/False</option>
                    </select>
                  </div>
                  <div className="col-md-4">
                    <label className="form-label">Difficulty</label>
                    <select
                      className="form-select"
                      value={q.difficulty}
                      onChange={e => updateQuestion(q.id, 'difficulty', e.target.value)}
                    >
                      <option value="EASY">Easy</option>
                      <option value="MEDIUM">Medium</option>
                      <option value="HARD">Hard</option>
                    </select>
                  </div>
                </div>

                <div className="mb-3">
                  <label className="form-label">Question Text</label>
                  <input
                    className="form-control"
                    value={q.questionText}
                    onChange={e => updateQuestion(q.id, 'questionText', e.target.value)}
                  />
                </div>

                {q.type === 'MCQ' && (
                  <div className="mt-3">
                    <h6>Choices</h6>
                    {q.choices.map((c, i) => (
                      <div key={i} className="input-group mb-2">
                        <div className="input-group-text">
                          <input
                            type="checkbox"
                            checked={c.isCorrect}
                            onChange={() => toggleCorrectChoice(q.id, i)}
                          />
                        </div>
                        <span className="input-group-text fw-bold">
                          {String.fromCharCode(65 + i)}
                        </span>
                        <input
                          className="form-control"
                          value={c.text}
                          onChange={e =>
                            updateQuestion(q.id, 'choices',
                              q.choices.map((cc, ci) =>
                                ci === i ? { ...cc, text: e.target.value } : cc
                              )
                            )
                          }
                        />
                        <button
                          className="btn btn-outline-danger"
                          onClick={() => deleteChoice(q.id, i)}
                        >
                          <FaTrash />
                        </button>
                      </div>
                    ))}
                    <button className="btn btn-sm btn-outline-secondary" onClick={() => addChoice(q.id)}>
                      <FaPlus className="me-1" /> Add Choice
                    </button>
                  </div>
                )}

                {q.type === 'TrueFalse' && (
                  <div className="mt-3">
                    <h6>True / False</h6>
                    {['True', 'False'].map((val, i) => (
                      <div key={i} className="form-check">
                        <input
                          type="radio"
                          className="form-check-input"
                          name={`tf-${q.id}`}
                          checked={q.choices[i]?.isCorrect || false}
                          onChange={() => toggleCorrectChoice(q.id, i)}
                        />
                        <label className="form-check-label">{val}</label>
                      </div>
                    ))}
                  </div>
                )}
              </>
            )}
          </div>
        ))}
      </div>

      {/* Save */}
      <div className="text-end">
        <button className="btn btn-success px-4" disabled={saving} onClick={handleSave}>
          <FaSave className="me-2" /> {saving ? 'Saving...' : 'Save Changes'}
        </button>
      </div>
    </div>
  )
}
