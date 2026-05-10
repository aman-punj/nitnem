import { useEffect, useMemo, useState } from 'react'

import { fetchContentList, upsertContentItem } from '../lib/contentService'
import { ContentItem } from '../lib/contentTypes'
import {
  initAuthPersistence,
  isAllowedAdminEmail,
  onAdminAuthChange,
  signInAdminWithGoogle,
  signOutAdmin,
} from '../lib/firebase'
import { PrayerCard } from '../components/admin/PrayerCard'
import { ContentEditor } from '../components/admin/ContentEditor'

type AuthStatus = 'checking' | 'signed_out' | 'signed_in' | 'error'

export function AdminApp() {
  const [authStatus, setAuthStatus] = useState<AuthStatus>('checking')
  const [authUserEmail, setAuthUserEmail] = useState('')
  const [authMessage, setAuthMessage] = useState('')
  const [authLoading, setAuthLoading] = useState(false)

  const [items, setItems] = useState<ContentItem[]>([])
  const [loadingItems, setLoadingItems] = useState(false)
  const [itemsError, setItemsError] = useState('')
  const [search, setSearch] = useState('')

  const [editingItem, setEditingItem] = useState<ContentItem | null>(null)
  const [isAddingNew, setIsAddingNew] = useState(false)

  const isAuthed = authStatus === 'signed_in'

  const filteredItems = useMemo(() => {
    const q = search.trim().toLowerCase()
    if (!q) return items
    return items.filter((item) => {
      const t = (item.titles.en || item.id).toLowerCase()
      return t.includes(q) || item.id.toLowerCase().includes(q)
    })
  }, [items, search])

  useEffect(() => {
    let unsub = () => {}

    void (async () => {
      try {
        await initAuthPersistence()
        unsub = onAdminAuthChange((user) => {
          if (!user) {
            setAuthStatus('signed_out')
            setAuthUserEmail('')
            return
          }
          if (!isAllowedAdminEmail(user.email)) {
            setAuthStatus('error')
            setAuthMessage('Signed in account is not authorized for admin access.')
            setAuthUserEmail(user.email ?? '')
            return
          }
          setAuthStatus('signed_in')
          setAuthUserEmail(user.email ?? '')
          setAuthMessage('')
        })
      } catch (error) {
        setAuthStatus('error')
        setAuthMessage(error instanceof Error ? error.message : 'Failed to initialize authentication.')
      }
    })()

    return () => unsub()
  }, [])

  useEffect(() => {
    if (!isAuthed) return
    void loadContentList()
  }, [isAuthed])

  async function loadContentList(): Promise<void> {
    setLoadingItems(true)
    setItemsError('')
    try {
      const list = await fetchContentList()
      setItems(list)
    } catch (error) {
      setItemsError(error instanceof Error ? error.message : 'Failed to load content list.')
    } finally {
      setLoadingItems(false)
    }
  }

  async function onSignIn(): Promise<void> {
    setAuthLoading(true)
    setAuthMessage('')
    try {
      const user = await signInAdminWithGoogle()
      setAuthStatus('signed_in')
      setAuthUserEmail(user.email ?? '')
    } catch (error) {
      setAuthStatus('error')
      setAuthMessage(error instanceof Error ? error.message : 'Google sign-in failed.')
    } finally {
      setAuthLoading(false)
    }
  }

  async function onLogout(): Promise<void> {
    setAuthLoading(true)
    setAuthMessage('')
    try {
      await signOutAdmin()
      setAuthStatus('signed_out')
      setAuthUserEmail('')
      setEditingItem(null)
      setIsAddingNew(false)
    } catch (error) {
      setAuthStatus('error')
      setAuthMessage(error instanceof Error ? error.message : 'Logout failed.')
    } finally {
      setAuthLoading(false)
    }
  }

  const handleSaveItem = async (item: ContentItem) => {
    await upsertContentItem(item)
    await loadContentList()
    setEditingItem(null)
    setIsAddingNew(false)
  }

  return (
    <div className="app fade-in">
      <header className="row spread" style={{ marginBottom: '40px' }}>
        <h1>Nitnem Admin</h1>
        {isAuthed && (
          <div className="row">
            <span className="info-text">Admin: {authUserEmail}</span>
            <button className="secondary" onClick={() => void onLogout()} disabled={authLoading}>
              Logout
            </button>
          </div>
        )}
      </header>

      {authStatus === 'checking' && (
        <div className="card empty-state">Checking session...</div>
      )}

      {authStatus === 'signed_out' && (
        <div className="card empty-state">
          <h2>Admin Access</h2>
          <p>Please sign in with an authorized account to manage content.</p>
          <button style={{ marginTop: '16px' }} onClick={() => void onSignIn()} disabled={authLoading}>
            {authLoading ? 'Signing In...' : 'Sign in with Google'}
          </button>
          {authMessage && <p className="error-text">{authMessage}</p>}
        </div>
      )}

      {authStatus === 'error' && (
        <div className="card empty-state">
          <h2 className="error-text">Unauthorized</h2>
          <p>{authMessage}</p>
          <button style={{ marginTop: '16px' }} onClick={() => void onLogout()}>Sign Out</button>
        </div>
      )}

      {isAuthed && (
        <div className="stack">
          {(editingItem || isAddingNew) ? (
            <ContentEditor 
              item={editingItem} 
              onSave={handleSaveItem} 
              onClose={() => { setEditingItem(null); setIsAddingNew(false); }} 
            />
          ) : (
            <div className="stack">
              <div className="row spread">
                <div className="row" style={{ flex: 1 }}>
                  <input 
                    style={{ flex: 1, maxWidth: '400px' }}
                    value={search} 
                    onChange={(e) => setSearch(e.target.value)} 
                    placeholder="Search prayers by title or ID..." 
                  />
                  {loadingItems && <span className="info-text">Refreshing...</span>}
                </div>
                <button onClick={() => setIsAddingNew(true)}>+ Add Content</button>
              </div>

              {itemsError && <div className="card error-text">{itemsError}</div>}
              
              {!loadingItems && filteredItems.length === 0 && (
                <div className="card empty-state">
                  No content found. Create your first prayer or YouTube live item!
                </div>
              )}

              <div className="grid">
                {filteredItems.map(item => (
                  <PrayerCard 
                    key={item.id} 
                    item={item} 
                    onEdit={() => setEditingItem(item)} 
                  />
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
