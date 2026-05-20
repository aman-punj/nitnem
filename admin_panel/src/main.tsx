import React, { useEffect, useState } from 'react'
import { createRoot } from 'react-dom/client'
import { type User } from 'firebase/auth'
import { AdminApp } from './pages/AdminApp'
import { LoginPage } from './components/LoginPage'
import { onAdminAuthChange, signOutAdmin } from './lib/firebase'
import './styles.css'

function App() {
  const [user, setUser] = useState<User | null | 'loading'>('loading')

  useEffect(() => {
    return onAdminAuthChange(setUser)
  }, [])

  if (user === 'loading') {
    return (
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh' }}>
        <p className="info-text">Loading…</p>
      </div>
    )
  }

  if (!user) return <LoginPage />

  return (
    <>
      <div style={{
        position: 'fixed', top: 12, right: 16, zIndex: 999,
        display: 'flex', gap: '10px', alignItems: 'center',
      }}>
        <span className="info-text" style={{ fontSize: '12px' }}>{user.email}</span>
        <button
          className="secondary"
          style={{ fontSize: '12px', padding: '4px 10px' }}
          onClick={() => void signOutAdmin()}
        >
          Sign out
        </button>
      </div>
      <AdminApp />
    </>
  )
}

createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
