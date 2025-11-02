import React, { createContext, useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

export const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [isLoading, setIsLoading] = useState(true)
  const navigate = useNavigate()

  useEffect(() => {
    const token = localStorage.getItem('token')
    const role = localStorage.getItem('role')
    const username = localStorage.getItem('username')

    if (token && role) {
      setUser({ token, role, username })
    }
    setIsLoading(false)
  }, [])

  const logout = () => {
    localStorage.clear()
    setUser(null)
    navigate('/',{replace:true})
  }

  // ✅ รอโหลดก่อน render
  if (isLoading) return null

  return (
    <AuthContext.Provider value={{ user, setUser, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

