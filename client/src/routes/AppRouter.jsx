import React from 'react'
import { Routes, Route } from 'react-router-dom'
import InstructorLayout from '../layouts/InstructorLayout.jsx'
import Home from '../pages/Auth/Home.jsx'
import InstructorDashboard from '../pages/Instructor/Dashboard.jsx'
import InstructorProfile from '../pages/Instructor/Profile.jsx'
import CreateExam from '../pages/Instructor/CreateExam.jsx'
import ViewExam from '../pages/Instructor/ViewExam.jsx'
import EditExam from '../pages/Instructor/EditExam.jsx'
import StudentDashboard from '../pages/Student/Dashboard.jsx'
import Exam from '../pages/Student/Exam.jsx'
import NotFound from '../pages/NotFound.jsx'
import ProtectedRoute from './ProtectedRoute.jsx'
import StudentProfile from '../pages/Student/Profile.jsx'
import Result from '../pages/Student/Result.jsx'

export default function AppRouter() {
  return (
    <Routes>
      
      {/* <Route element={<MainLayout />}> */}
        <Route path="/" element={<Home />} />
      

      {/* Instructor */}
      <Route element={<ProtectedRoute role="instructor" />}>
        <Route element={<InstructorLayout />}>
          <Route path="/instructor/dashboard" element={<InstructorDashboard />} />
          <Route path="/instructor/profile" element={<InstructorProfile />} />
          <Route path="/instructor/create" element={<CreateExam />} />
          <Route path="/instructor/exam/:id" element={<ViewExam />} />
          <Route path="/instructor/exam/:id/edit" element={<EditExam />} />


        </Route>
      </Route>

      {/* Student */}
      <Route element={<ProtectedRoute role="student" />}>
        <Route path="/student/dashboard" element={<StudentDashboard />} />
        <Route path="/student/profile" element={<StudentProfile />} />
        <Route path="/exam/:id" element={<Exam />} />
        <Route path="/student/exam/:id/result/:attemptId" element={<Result />} />

      </Route>

      {/* Fallback */}
      <Route path="*" element={<NotFound />} />
    </Routes>
  )
}
