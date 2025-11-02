// client/src/api.js
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL;

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// ---------- 🧩 รวม API แยกตามหมวด ----------

// 🔐 Auth API
export const AuthAPI = {
  login: (data) => api.post('/api/auth/login', data),
  register: (data) => api.post('/api/auth/register', data),
};

// 👨‍🏫 Instructor API
export const InstructorAPI = {
  getDashboard: (token) =>
    api.get('/api/instructor/dashboard', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  getExamById: (id, token) =>
    api.get(`/api/instructor/exam/${id}`, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  createExam: (data, token) =>
    api.post('/api/instructor/exam', data, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  updateExam: (id, data, token) =>
    api.put(`/api/instructor/exam/${id}`, data, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  deleteExam: (id, token) =>
    api.delete(`/api/instructor/exam/${id}`, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  updateExamStatus: (examId, status, token) =>
    api.put(
      `/api/instructor/exam/${examId}/status`,
      { status },
      { headers: { Authorization: `Bearer ${token}` } }
    ),

  searchExams: (query, token) =>
    api.get(`/api/instructor/search?q=${encodeURIComponent(query)}`, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  // ✅ โหลดหมวดหมู่ทั้งหมด (สำหรับ dropdown ใน CreateExam)
  getCategories: (token) =>
    api.get('/api/instructor/categories', {
      headers: { Authorization: `Bearer ${token}` },
    }),
    getProfile: (token) =>
    api.get('/api/instructor/profile', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  updateProfile: (data, token) =>
    api.put('/api/instructor/profile', data, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  deleteProfile: (token) =>
    api.delete('/api/instructor/profile', {
      headers: { Authorization: `Bearer ${token}` },
    }),
  
};

// 👨‍🎓 Student API
export const StudentAPI = {
  getDashboard: (token) =>
    api.get('/api/student/dashboard', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  getExam: (id, token) =>
    api.get(`/api/student/exam/${id}`, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  submitExam: (id, answers, token) =>
    api.post(`/api/student/exam/${id}/submit`, { answers }, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  getResult: (examId, attemptId, token) =>
    api.get(`/api/student/exam/${examId}/result/${attemptId}`, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  getProfile: (token) =>
    api.get('/api/student/profile', {
      headers: { Authorization: `Bearer ${token}` },
    }),

  updateProfile: (data, token) =>
    api.put('/api/student/profile', data, {
      headers: { Authorization: `Bearer ${token}` },
    }),

  deleteProfile: (token) =>
    api.delete('/api/student/profile', {
      headers: { Authorization: `Bearer ${token}` },
    }),
};
