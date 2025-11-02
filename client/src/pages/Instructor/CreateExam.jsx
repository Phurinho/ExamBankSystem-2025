import React, { useState, useEffect } from 'react'
import { FaPlus, FaTrash, FaChevronDown, FaChevronUp } from 'react-icons/fa'
import { InstructorAPI } from '../../api'
import axios from 'axios' // ✅ ใช้ axios แค่โหลด categories


export default function CreateExam() {
  const [examMeta, setExamMeta] = useState({
    examName: '',
    course: '',
    topic: '',
    category: '', // dropdown (CategoryName)
  })
  const [categories, setCategories] = useState([])
  const [questions, setQuestions] = useState([])
  const [activeQuestion, setActiveQuestion] = useState(null)
  const token = localStorage.getItem('token')

  // ✅ โหลดหมวดหมู่ทั้งหมดจาก backend
  const loadCategories = async () => {
  try {
    const res = await InstructorAPI.getCategories(token)
    setCategories(res.data || [])
  } catch (err) {
    console.error('❌ Load categories failed:', err)
    setCategories([])
  }
}


  useEffect(() => { loadCategories() }, [])

  // ✅ ตรวจว่ากรอกครบหรือยัง
  const isMetaComplete =
    examMeta.examName.trim() && examMeta.course.trim() && examMeta.topic.trim() && examMeta.category.trim()

  // ➕ เพิ่มคำถามใหม่
  const addQuestion = () => {
    if (!isMetaComplete) {
      alert('Please fill Exam Name, Course, Topic, and select Category before adding questions.')
      return
    }

    const newQ = {
      id: Date.now(),
      type: 'MCQ',
      difficulty: 'MEDIUM',
      questionText: '',
      choices: [
        { text: '', isCorrect: false },
        { text: '', isCorrect: false }
      ]
    }
    setQuestions(prev => [...prev, newQ])
    setActiveQuestion(newQ.id)
  }

  // 🗑️ ลบคำถาม
  const deleteQuestion = id => setQuestions(prev => prev.filter(q => q.id !== id))

  // 🧩 อัปเดตคำถาม
  const updateQuestion = (id, key, value) =>
    setQuestions(prev => prev.map(q => (q.id === id ? { ...q, [key]: value } : q)))

  // ➕ เพิ่ม / ลบ / อัปเดต choice
  const addChoice = id =>
    setQuestions(prev =>
      prev.map(q =>
        q.id === id
          ? { ...q, choices: [...q.choices, { text: '', isCorrect: false }] }
          : q
      )
    )

  const deleteChoice = (qid, idx) =>
    setQuestions(prev =>
      prev.map(q =>
        q.id === qid
          ? { ...q, choices: q.choices.filter((_, i) => i !== idx) }
          : q
      )
    )

  const updateChoiceText = (qid, idx, value) =>
    setQuestions(prev =>
      prev.map(q =>
        q.id === qid
          ? {
              ...q,
              choices: q.choices.map((c, i) =>
                i === idx ? { ...c, text: value } : c
              ),
            }
          : q
      )
    )

  const toggleCorrectChoice = (qid, idx) =>
    setQuestions(prev =>
      prev.map(q =>
        q.id === qid
          ? {
              ...q,
              choices: q.choices.map((c, i) => ({
                ...c,
                isCorrect: i === idx, // ✅ ให้เลือกถูกได้แค่ข้อเดียว
              })),
            }
          : q
      )
    )

  const toggleQuestion = id => setActiveQuestion(activeQuestion === id ? null : id)

  // ✅ บันทึกข้อมูลไป backend
  const handleSave = async () => {
    try {
      if (questions.length === 0) {
        alert('Please add at least one question before saving.')
        return
      }

      const payload = {
        examName: examMeta.examName,
        categoryName: examMeta.category, // ✅ ส่งชื่อ category ที่เลือก
        courseCode: examMeta.course,
        courseName: examMeta.course,
        topicName: examMeta.topic,
        status: 'draft',
        questions: questions.map(q => ({
          questionText: q.questionText,
          typeCode: q.type === 'MCQ' ? 'MCQ' : 'TF',
          difficulty: q.difficulty,
          points: 1,
          choices:
            q.type === 'MCQ' || q.type === 'TrueFalse'
              ? q.choices.map(c => ({
                  text: c.text,
                  isCorrect: c.isCorrect
                }))
              : []
        }))
      }

      const res = await InstructorAPI.createExam(payload, token)

      if (res.status === 201) {
        alert('✅ Exam created successfully!')
        console.log('Response:', res.data)
      } else {
        alert('⚠️ Save failed: ' + res.statusText)
      }
    } catch (err) {
      console.error('❌ Save exam error:', err)
      alert(err.response?.data?.error || 'Failed to save exam.')
    }
  }

  // ===================== UI =====================
  return (
    <div className="container py-4">
      <h2 className="text-center mb-4 fw-bold text-primary">Create Exam</h2>

      {/* Exam Info Section */}
      <div className="card p-3 mb-4 shadow-sm">
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

          {/* ✅ Category dropdown */}
          <div className="col-md-3">
            <label className="form-label">Category</label>
            <select
              className="form-select"
              value={examMeta.category}
              onChange={e => setExamMeta({ ...examMeta, category: e.target.value })}
            >
              <option value="">-- Select Category --</option>
              {categories.map(cat => (
                <option key={cat.CategoryID} value={cat.CategoryName}>
                  {cat.CategoryName}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Questions Section */}
      <div className="mb-4">
        <div className="d-flex justify-content-between align-items-center mb-3">
          <h5 className="fw-bold">Questions ({questions.length})</h5>
          <button
            className="btn btn-sm btn-dark"
            onClick={addQuestion}
            disabled={!isMetaComplete}
          >
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
                    {q.choices.map((c, i) => {
                      const label = String.fromCharCode(65 + i)
                      return (
                        <div key={i} className="input-group mb-2">
                          <div className="input-group-text">
                            <input
                              type="checkbox"
                              checked={c.isCorrect}
                              onChange={() => toggleCorrectChoice(q.id, i)}
                            />
                          </div>
                          <span className="input-group-text fw-bold">{label}</span>
                          <input
                            className="form-control"
                            placeholder={`Option ${label}`}
                            value={c.text}
                            onChange={e => updateChoiceText(q.id, i, e.target.value)}
                          />
                          <button
                            className="btn btn-outline-danger"
                            onClick={() => deleteChoice(q.id, i)}
                          >
                            <FaTrash />
                          </button>
                        </div>
                      )
                    })}
                    <button
                      className="btn btn-sm btn-outline-secondary"
                      onClick={() => addChoice(q.id)}
                    >
                      <FaPlus className="me-1" /> Add New Choice
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

      <div className="text-end">
        <button className="btn btn-success px-4" onClick={handleSave}>
          Save Exam
        </button>
      </div>
    </div>
  )
}
