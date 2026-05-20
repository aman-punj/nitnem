import { useState } from 'react'
import { signInAdmin } from '../lib/firebase'

export function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    if (!email.trim() || !password) return
    setLoading(true)
    setError('')
    try {
      await signInAdmin(email.trim(), password)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Sign-in failed.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
    }}>
      <div className="card" style={{ width: '100%', maxWidth: '380px' }}>
        <h2 style={{ marginBottom: '4px' }}>Nitnem Admin</h2>
        <p className="info-text" style={{ marginBottom: '24px' }}>
          Sign in to continue
        </p>

        <form onSubmit={(e) => void handleSubmit(e)} className="stack" style={{ gap: '14px' }}>
          <div className="field-group">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              placeholder="you@example.com"
              autoComplete="email"
              required
            />
          </div>

          <div className="field-group">
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="••••••••"
              autoComplete="current-password"
              required
            />
          </div>

          {error && (
            <p style={{ color: 'var(--error)', fontSize: '13px', margin: 0 }}>
              {error}
            </p>
          )}

          <button type="submit" disabled={loading} style={{ marginTop: '4px' }}>
            {loading ? 'Signing in…' : 'Sign in'}
          </button>
        </form>
      </div>
    </div>
  )
}
