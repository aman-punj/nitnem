import { useEffect, useMemo, useState } from 'react'
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core'
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
  useSortable,
} from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'

import { fetchContentList, upsertContentItem } from '../lib/contentService'
import { ContentItem } from '../lib/contentTypes'
import {
  initAuthPersistence,
  isAllowedAdminEmail,
  onAdminAuthChange,
  signInAdminWithGoogle,
  signOutAdmin,
} from '../lib/firebase'
import { fetchRemoteConfig, saveRemoteConfig } from '../lib/remoteConfigService'
import { DEFAULT_REMOTE_CONFIG, type RemoteConfig } from '../lib/remoteConfigTypes'
import { PrayerCard } from '../components/admin/PrayerCard'
import { ContentEditor } from '../components/admin/ContentEditor'
import { RemoteConfigEditor } from '../components/admin/RemoteConfigEditor'

type AuthStatus = 'checking' | 'signed_out' | 'signed_in' | 'error'
type AdminSection =
  | 'dashboard'
  | 'content'
  | 'categories'
  | 'feedback'
  | 'live'
  | 'app_config'
  | 'version_control'
  | 'feature_flags'
  | 'maintenance'
  | 'languages'
  | 'experimental'
  | 'storage'
  | 'settings'

function SortableItem({ item, onEdit }: { item: ContentItem; onEdit: () => void }) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: item.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    zIndex: isDragging ? 100 : 1,
    opacity: isDragging ? 0.5 : 1,
  }

  return (
    <div ref={setNodeRef} style={style}>
      <PrayerCard 
        item={item} 
        onEdit={onEdit} 
        dragHandleProps={{ ...attributes, ...listeners }}
      />
    </div>
  )
}

export function AdminApp() {
  const [section, setSection] = useState<AdminSection>('content')
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

  const [remoteConfig, setRemoteConfig] = useState<RemoteConfig>(DEFAULT_REMOTE_CONFIG)
  const [remoteConfigLoading, setRemoteConfigLoading] = useState(false)
  const [remoteConfigError, setRemoteConfigError] = useState('')
  const [dirtyRemoteConfig, setDirtyRemoteConfig] = useState(false)
  const [publishing, setPublishing] = useState(false)

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  )

  const isAuthed = authStatus === 'signed_in'

  const { pinnedItems, normalItems } = useMemo(() => {
    const sorted = [...items].sort((a, b) => {
      if (a.pinToTop !== b.pinToTop) return a.pinToTop ? -1 : 1
      return (a.displayOrder ?? 0) - (b.displayOrder ?? 0)
    })

    const filtered = search.trim().toLowerCase()
      ? sorted.filter((item) => {
          const t = (item.titles.en || item.id).toLowerCase()
          return (
            t.includes(search.toLowerCase()) ||
            item.id.toLowerCase().includes(search.toLowerCase())
          )
        })
      : sorted

    return {
      pinnedItems: filtered.filter((i) => i.pinToTop),
      normalItems: filtered.filter((i) => !i.pinToTop),
    }
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
    void loadRemoteConfig()
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

  async function loadRemoteConfig(): Promise<void> {
    setRemoteConfigLoading(true)
    setRemoteConfigError('')
    try {
      const data = await fetchRemoteConfig()
      setRemoteConfig(data)
      setDirtyRemoteConfig(false)
    } catch (error) {
      setRemoteConfigError(error instanceof Error ? error.message : 'Failed to load remote config.')
    } finally {
      setRemoteConfigLoading(false)
    }
  }

  async function publishRemoteConfig(): Promise<void> {
    setPublishing(true)
    try {
      const saved = await saveRemoteConfig(remoteConfig)
      setRemoteConfig(saved)
      setDirtyRemoteConfig(false)
    } catch (error) {
      setRemoteConfigError(error instanceof Error ? error.message : 'Failed to publish config.')
    } finally {
      setPublishing(false)
    }
  }

  function handleRemoteConfigChange(nextConfig: RemoteConfig) {
    setRemoteConfig(nextConfig)
    setDirtyRemoteConfig(true)
  }

  async function onSignIn(): Promise<void> {
    setAuthLoading(true)
    setAuthMessage('')
    try {
      const user = await signInAdminWithGoogle()
      setAuthStatus('signed_in')
      setAuthUserEmail(user.email ?? '')
    } catch (error) {
      const code = (error as { code?: string })?.code
      if (code === 'auth/popup-closed-by-user' || code === 'auth/cancelled-popup-request') {
        setAuthStatus('signed_out')
        setAuthMessage(
          'Google sign-in did not complete. If you did not close the popup, please allow popups in your browser and try again. (' + code + ')' 
        )
      } else {
        setAuthStatus('error')
        setAuthMessage(error instanceof Error ? error.message : `Google sign-in failed. ${(error as any)?.code ?? ''}`)
      }
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

  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event
    if (!over || active.id === over.id) return

    const activeItem = items.find((i) => i.id === active.id)
    const overItem = items.find((i) => i.id === over.id)
    if (!activeItem || !overItem) return

    // If crossing sections (Pinned <-> Normal), we don't handle that via drag yet
    // as per task "When pinToTop is enabled: item moves into pinned section... When disabled: item returns to normal section"
    // Usually handled by the Edit toggle.
    if (activeItem.pinToTop !== overItem.pinToTop) return

    // Reorder within the FULL (unfiltered) list to maintain consistent displayOrder
    const fullSectionItems = items
      .filter(i => i.pinToTop === activeItem.pinToTop)
      .sort((a, b) => a.displayOrder - b.displayOrder)

    const oldIndex = fullSectionItems.findIndex((i) => i.id === active.id)
    const newIndex = fullSectionItems.findIndex((i) => i.id === over.id)

    const reorderedSection = arrayMove(fullSectionItems, oldIndex, newIndex)
    
    // Update displayOrder for ALL items in this section
    const updatedItems = reorderedSection.map((item, index) => ({
      ...item,
      displayOrder: index,
    }))

    // Optimistic Update
    const nextItems = items.map((item) => {
      const updated = updatedItems.find((u) => u.id === item.id)
      return updated || item
    })
    setItems(nextItems)

    // Persist to Firestore in background
    try {
      await Promise.all(updatedItems.map((item) => upsertContentItem(item)))
    } catch (error) {
      console.error('Failed to persist new order:', error)
      await loadContentList() // Rollback on error
    }
  }

  const handleSaveItem = async (item: ContentItem) => {
    await upsertContentItem(item)
    await loadContentList()
    setEditingItem(null)
    setIsAddingNew(false)
  }

  function formatTimestampLabel(value: unknown) {
    if (!value) return 'Never published'
    const timestamp = value as any
    if (timestamp?.toDate) {
      return timestamp.toDate().toLocaleString()
    }
    if (timestamp instanceof Date) {
      return timestamp.toLocaleString()
    }
    if (typeof timestamp === 'string') {
      return timestamp
    }
    return 'Recently'
  }

  const sectionMenu: Array<{ id: AdminSection; label: string }> = [
    { id: 'dashboard', label: 'Dashboard' },
    { id: 'app_config', label: 'App Config' },
    { id: 'version_control', label: 'Version Control' },
    { id: 'feature_flags', label: 'Feature Flags' },
    { id: 'maintenance', label: 'Maintenance' },
    { id: 'languages', label: 'Languages' },
    { id: 'experimental', label: 'Experimental' },
    { id: 'content', label: 'Content' },
    { id: 'settings', label: 'Settings' },
  ]

  const isContentSection = section === 'content'
  const isRemoteConfigSection = ['app_config', 'version_control', 'feature_flags', 'maintenance', 'languages', 'experimental'].includes(section)

  return (
    <div className="app fade-in">
      <header className="row spread" style={{ marginBottom: '40px' }}>
        <div>
          <h1>Nitnem Admin</h1>
          <p className="info-text">Premium internal control center for Bani Sagar mobile configuration.</p>
        </div>
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
        <div className="admin-layout">
          <aside className="admin-sidebar card">
            {sectionMenu.map((entry) => (
              <button
                key={entry.id}
                className={section === entry.id ? '' : 'secondary'}
                style={{ width: '100%', marginBottom: '8px' }}
                onClick={() => setSection(entry.id)}
              >
                {entry.label}
              </button>
            ))}
          </aside>
          <main className="stack" style={{ flex: 1 }}>
            {isRemoteConfigSection && (
              <div className="stack">
                <div className="row spread top-bar" style={{ marginBottom: '24px' }}>
                  <div className="stack" style={{ flex: 1, minWidth: 0 }}>
                    <span className="eyebrow">Config controls</span>
                    <div className="row" style={{ gap: '12px', flexWrap: 'wrap' }}>
                      <span className="info-text">Environment: {remoteConfig.environment}</span>
                      <span className="info-text">Last updated: {formatTimestampLabel(remoteConfig.updatedAt)}</span>
                      {dirtyRemoteConfig && <span className="badge accent">Unsaved changes</span>}
                    </div>
                  </div>
                  <div className="row" style={{ gap: '12px', flexWrap: 'wrap' }}>
                    <button className="secondary" onClick={() => void loadRemoteConfig()} disabled={remoteConfigLoading || publishing}>
                      Refresh
                    </button>
                    <button onClick={() => void publishRemoteConfig()} disabled={!dirtyRemoteConfig || publishing || remoteConfigLoading}>
                      {publishing ? 'Publishing...' : 'Publish Changes'}
                    </button>
                  </div>
                </div>

                {remoteConfigError && <div className="card error-text">{remoteConfigError}</div>}
                {remoteConfigLoading ? (
                  <div className="card empty-state">Loading configuration...</div>
                ) : (
                  <RemoteConfigEditor
                    remoteConfig={remoteConfig}
                    activeSection={section}
                    onChange={handleRemoteConfigChange}
                    saving={publishing}
                    lastPublishedLabel={formatTimestampLabel(remoteConfig.updatedAt)}
                    updatedBy={remoteConfig.updatedBy ?? ''}
                    dirty={dirtyRemoteConfig}
                  />
                )}
              </div>
            )}

            {section === 'dashboard' && (
              <div className="card">
                <h2>Operational Dashboard</h2>
                <p className="field-description">A calm cockpit for configuration, releases, and maintenance state.</p>
                <div className="grid" style={{ marginTop: '20px' }}>
                  <div className="card small-card">
                    <p className="field-label">Current environment</p>
                    <strong>{remoteConfig.environment}</strong>
                  </div>
                  <div className="card small-card">
                    <p className="field-label">Remote config state</p>
                    <strong>{dirtyRemoteConfig ? 'Unsaved changes' : 'Synced'}</strong>
                  </div>
                  <div className="card small-card">
                    <p className="field-label">Maintenance</p>
                    <strong>{remoteConfig.maintenance.isUnderMaintenance ? 'Active' : 'Inactive'}</strong>
                  </div>
                </div>
              </div>
            )}

            {section === 'settings' && (
              <div className="card">
                <h2>Settings</h2>
                <p className="field-description">General admin preferences and access controls for the panel.</p>
                <div className="stack" style={{ marginTop: '20px' }}>
                  <div className="field-group">
                    <label>Admin account</label>
                    <input readOnly value={authUserEmail} />
                  </div>
                </div>
              </div>
            )}

            {isContentSection && (
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

                    {!loadingItems && items.length === 0 && (
                      <div className="card empty-state">
                        No content found. Create your first prayer or YouTube live item!
                      </div>
                    )}

                    <DndContext
                      sensors={sensors}
                      collisionDetection={closestCenter}
                      onDragEnd={handleDragEnd}
                    >
                      {pinnedItems.length > 0 && (
                        <div className="stack" style={{ marginTop: '20px' }}>
                          <h2 style={{ fontSize: '1.2rem', color: 'var(--accent)' }}>Pinned Content</h2>
                          <SortableContext items={pinnedItems.map(i => i.id)} strategy={verticalListSortingStrategy}>
                            <div className="grid">
                              {pinnedItems.map((item) => (
                                <SortableItem key={item.id} item={item} onEdit={() => setEditingItem(item)} />
                              ))}
                            </div>
                          </SortableContext>
                        </div>
                      )}

                      <div className="stack" style={{ marginTop: '20px' }}>
                        <h2 style={{ fontSize: '1.2rem' }}>All Content</h2>
                        <SortableContext items={normalItems.map(i => i.id)} strategy={verticalListSortingStrategy}>
                          <div className="grid">
                            {normalItems.map((item) => (
                              <SortableItem key={item.id} item={item} onEdit={() => setEditingItem(item)} />
                            ))}
                          </div>
                        </SortableContext>
                      </div>
                    </DndContext>
                  </div>
                )}
              </div>
            )}
          </main>
        </div>
      )}
    </div>
  )
}
