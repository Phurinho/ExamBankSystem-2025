import React, { useEffect, useState, useContext } from 'react'
import { FaSave, FaUserGraduate, FaTrash, FaArrowLeft } from 'react-icons/fa'
import { useNavigate } from 'react-router-dom'
import { StudentAPI } from '../../api'
import { AuthContext } from '../../context/AuthContext' // ✅ ดึง context

export default function StudentProfile() {
  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const { user, setUser } = useContext(AuthContext) // ✅ ใช้ context
  const token = user?.token || localStorage.getItem('token')
  const navigate = useNavigate()

  // ✅ โหลดข้อมูลโปรไฟล์นักศึกษา
  const loadProfile = async () => {
    try {
      const res = await StudentAPI.getProfile(token)
      setProfile(res.data.user)
    } catch (err) {
      console.error('❌ Load profile failed:', err)
      alert(err.response?.data?.error || 'Failed to load profile.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { loadProfile() }, [])

  // ✅ บันทึกโปรไฟล์
  const handleSave = async () => {
    setSaving(true)
    try {
      const payload = {
        username: profile.Username,
        email: profile.Email,
        department: profile.Department,
        studentId: profile.StudentID
      }

      await StudentAPI.updateProfile(payload, token)
      alert('Profile updated successfully!')

      // ✅ อัปเดต AuthContext + localStorage ให้ชื่อใหม่ sync ทุกหน้า
      setUser((prev) => ({
        ...prev,
        username: profile.Username
      }))
      localStorage.setItem('username', profile.Username)

      // ✅ กลับไป Dashboard เพื่อให้เห็นชื่อใหม่ทันที
      navigate('/student/dashboard', { replace: true })
    } catch (err) {
      console.error('❌ Save failed:', err.response?.data || err)
      alert(err.response?.data?.error || 'Failed to save profile.')
    } finally {
      setSaving(false)
    }
  }

  // ✅ ลบบัญชีผู้ใช้
  const handleDeleteAccount = async () => {
    try {
      await StudentAPI.deleteProfile(token)
      alert('Account deleted successfully!')
      localStorage.clear()
      navigate('/', { replace: true })
    } catch (err) {
      console.error('❌ Delete failed:', err)
      alert(err.response?.data?.error || 'Failed to delete account.')
    }
  }

  if (loading) return <div className="text-center mt-5">Loading profile...</div>
  if (!profile) return <div className="text-center text-danger mt-5">No profile data found.</div>

  return (
    <div className="container py-5">
      {/* Header + Back button */}
      <div className="d-flex justify-content-between align-items-center mb-4">
        <h2 className="fw-bold text-primary mb-0">
          <FaUserGraduate className="me-2" /> Student Profile
        </h2>
        <button
          type="button"
          className="btn btn-secondary"
          onClick={() => navigate('/student/dashboard')}
        >
          <FaArrowLeft className="me-2" /> Back to Dashboard
        </button>
      </div>

      <div className="card p-4 shadow-sm">
        <div className="row g-3">
          <div className="col-md-6">
            <label className="form-label">Username</label>
            <input
              className="form-control"
              name="username"
              value={profile.Username}
              onChange={(e) =>
                setProfile((prev) => ({
                  ...prev,
                  Username: e.target.value,
                  username: e.target.value
                }))
              }
            />
          </div>

          <div className="col-md-6">
            <label className="form-label">Email</label>
            <input
              className="form-control"
              name="email"
              value={profile.Email}
              onChange={(e) =>
                setProfile((prev) => ({
                  ...prev,
                  Email: e.target.value,
                  email: e.target.value
                }))
              }
            />
          </div>

          <div className="col-md-6">
            <label className="form-label">Department</label>
            <input
              className="form-control"
              name="department"
              value={profile.Department || ''}
              onChange={(e) =>
                setProfile((prev) => ({
                  ...prev,
                  Department: e.target.value,
                  department: e.target.value
                }))
              }
            />
          </div>

          <div className="col-md-6">
            <label className="form-label">Student ID</label>
            <input
              className="form-control"
              name="studentId"
              value={profile.StudentID || ''}
              onChange={(e) =>
                setProfile((prev) => ({
                  ...prev,
                  StudentID: e.target.value,
                  studentId: e.target.value
                }))
              }
            />
          </div>

          <div className="col-md-6">
            <label className="form-label">Role</label>
            <input className="form-control" value={profile.Role} disabled />
          </div>
        </div>

        <div className="text-end mt-4">
          <button
            className="btn btn-success px-4 me-2"
            disabled={saving}
            onClick={handleSave}
          >
            <FaSave className="me-2" />
            {saving ? 'Saving...' : 'Save Changes'}
          </button>

          <button
            className="btn btn-outline-danger"
            onClick={() => setShowDeleteModal(true)}
          >
            <FaTrash className="me-1" /> Delete Account
          </button>
        </div>
      </div>

      {/* Modal ยืนยันลบ */}
      {showDeleteModal && (
        <div className="modal show fade d-block" tabIndex="-1">
          <div className="modal-dialog modal-dialog-centered">
            <div className="modal-content p-4 text-center">
              <h5 className="fw-bold mb-3 text-danger">Delete Account</h5>
              <p>
                Are you sure you want to permanently delete your account?<br />
                This action cannot be undone.
              </p>
              <div className="d-flex justify-content-center gap-3 mt-3">
                <button
                  className="btn btn-secondary"
                  onClick={() => setShowDeleteModal(false)}
                >
                  Cancel
                </button>
                <button
                  className="btn btn-danger"
                  onClick={handleDeleteAccount}
                >
                  Confirm
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
