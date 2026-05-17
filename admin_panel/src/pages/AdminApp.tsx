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

import { fetchContentList, upsertContentItem, deleteContentItem } from '../lib/contentService'
import { ContentItem } from '../lib/contentTypes'
import { 
  fetchRemoteConfig, 
  saveRemoteConfig,
  fetchMenuSettings,
  saveMenuSettings 
} from '../lib/remoteConfigService'
import { 
  DEFAULT_REMOTE_CONFIG, 
  type RemoteConfig,
  DEFAULT_MENU_SETTINGS,
  type MenuSettings
} from '../lib/remoteConfigTypes'
import { PrayerCard } from '../components/admin/PrayerCard'
import { ContentEditor } from '../components/admin/ContentEditor'
import { RemoteConfigEditor } from '../components/admin/RemoteConfigEditor'
import { MenuSettingsEditor } from '../components/admin/MenuSettingsEditor'
import { SupportAdminPanel } from '../components/admin/SupportAdminPanel'
import { fetchNotificationSettings, saveNotificationSettings } from '../lib/notificationsService'
import { DEFAULT_NOTIFICATION_SETTINGS, type NotificationSettings } from '../lib/notificationsTypes'
import { NotificationsEditor } from '../components/admin/NotificationsEditor'

type AdminSection = 'config' | 'content' | 'menu' | 'notifications' | 'support'

function SortableItem({ item, onEdit, onDelete }: { item: ContentItem; onEdit: () => void; onDelete: () => void }) {
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
        onDelete={onDelete}
        dragHandleProps={{ ...attributes, ...listeners }}
      />
    </div>
  )
}

export function AdminApp() {
  const [section, setSection] = useState<AdminSection>('config')

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

  const [menuSettings, setMenuSettings] = useState<MenuSettings>(DEFAULT_MENU_SETTINGS)
  const [menuLoading, setMenuLoading] = useState(false)
  const [menuError, setMenuError] = useState('')
  const [dirtyMenu, setDirtyMenu] = useState(false)

  const [notifSettings, setNotifSettings] = useState<NotificationSettings>(DEFAULT_NOTIFICATION_SETTINGS)
  const [notifLoading, setNotifLoading] = useState(false)
  const [notifError, setNotifError] = useState('')
  const [dirtyNotif, setDirtyNotif] = useState(false)

  const [publishing, setPublishing] = useState(false)

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  )

  const sortedItems = useMemo<ContentItem[]>(() => {
    const sorted = [...items].sort((a, b) => {
      return (a.displayOrder ?? 0) - (b.displayOrder ?? 0)
    })

    return search.trim().toLowerCase()
      ? sorted.filter((item: ContentItem) => {
          return (
            item.titles.en?.toLowerCase().includes(search.toLowerCase()) ||
            item.titles.pa?.toLowerCase().includes(search.toLowerCase()) ||
            item.titles.hi?.toLowerCase().includes(search.toLowerCase()) ||
            item.id.toLowerCase().includes(search.toLowerCase())
          )
        })
      : sorted
  }, [items, search])

  useEffect(() => {
    void loadContentList()
    void loadRemoteConfig()
    void loadMenuSettings()
    void loadNotifSettings()
  }, [])

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

  async function loadNotifSettings(): Promise<void> {
    setNotifLoading(true)
    setNotifError('')
    try {
      const data = await fetchNotificationSettings()
      setNotifSettings(data)
      setDirtyNotif(false)
    } catch (error) {
      setNotifError(error instanceof Error ? error.message : 'Failed to load notification settings.')
    } finally {
      setNotifLoading(false)
    }
  }

  async function loadMenuSettings(): Promise<void> {
    setMenuLoading(true)
    setMenuError('')
    try {
      const data = await fetchMenuSettings()
      setMenuSettings(data)
      setDirtyMenu(false)
    } catch (error) {
      setMenuError(error instanceof Error ? error.message : 'Failed to load menu settings.')
    } finally {
      setMenuLoading(false)
    }
  }

  async function publishChanges(): Promise<void> {
    setPublishing(true)
    try {
      if (dirtyRemoteConfig) {
        const saved = await saveRemoteConfig(remoteConfig)
        setRemoteConfig(saved)
        setDirtyRemoteConfig(false)
      }
      if (dirtyMenu) {
        const saved = await saveMenuSettings(menuSettings)
        setMenuSettings(saved)
        setDirtyMenu(false)
      }
      if (dirtyNotif) {
        const saved = await saveNotificationSettings(notifSettings)
        setNotifSettings(saved)
        setDirtyNotif(false)
      }
    } catch (error) {
      console.error('Failed to publish changes:', error)
      setRemoteConfigError(error instanceof Error ? error.message : 'Failed to publish changes.')
    } finally {
      setPublishing(false)
    }
  }

  function handleRemoteConfigChange(nextConfig: RemoteConfig) {
    setRemoteConfig(nextConfig)
    setDirtyRemoteConfig(true)
  }

  function handleMenuSettingsChange(nextSettings: MenuSettings) {
    setMenuSettings(nextSettings)
    setDirtyMenu(true)
  }

  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event
    if (!over || active.id === over.id) return

    const activeItem = items.find((i: ContentItem) => i.id === active.id)
    const overItem = items.find((i: ContentItem) => i.id === over.id)
    if (!activeItem || !overItem) return

    const fullSectionItems = items
      .sort((a: ContentItem, b: ContentItem) => (a.displayOrder ?? 0) - (b.displayOrder ?? 0))

    const oldIndex = fullSectionItems.findIndex((i: ContentItem) => i.id === active.id)
    const newIndex = fullSectionItems.findIndex((i: ContentItem) => i.id === over.id)

    const reorderedSection = arrayMove(fullSectionItems, oldIndex, newIndex)

    const updatedItems = reorderedSection.map((item: ContentItem, index: number) => ({
      ...item,
      displayOrder: index,
    }))

    const nextItems = items.map((item: ContentItem) => {
      const updated = updatedItems.find((u: ContentItem) => u.id === item.id)
      return updated || item
    })
    setItems(nextItems)

    try {
      await Promise.all(updatedItems.map((item: ContentItem) => upsertContentItem(item)))
    } catch (error) {
      console.error('Failed to persist new order:', error)
      await loadContentList()
    }
  }

  const handleSaveItem = async (item: ContentItem) => {
    await upsertContentItem(item)
    await loadContentList()
    setEditingItem(null)
    setIsAddingNew(false)
  }

  const handleDeleteItem = async (item: ContentItem) => {
    if (!confirm(`Are you sure you want to permanently delete "${item.titles.en}"?`)) {
      return
    }

    try {
      await deleteContentItem(item.id)
      await loadContentList()
    } catch (error) {
      console.error('Failed to delete item:', error)
      setItemsError('Failed to delete item.')
    }
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

  return (
    <div className="app fade-in">
      <header className="row spread" style={{ marginBottom: '40px' }}>
        <div>
          <h1>Nitnem Admin</h1>
          <p className="info-text">Premium internal control center for Bani Sagar mobile configuration.</p>
        </div>
      </header>

      {/* Shared Toolbar */}
      <div className="row spread top-bar" style={{ marginBottom: '24px' }}>
        <div className="stack" style={{ flex: 1, minWidth: 0 }}>
          <span className="eyebrow">Controls</span>
          <div className="row" style={{ gap: '12px', flexWrap: 'wrap' }}>
            <span className="info-text">
              Last Config Update: {formatTimestampLabel(remoteConfig.updatedAt)} | 
              Last Menu Update: {formatTimestampLabel(menuSettings.updatedAt)}
            </span>
            {(dirtyRemoteConfig || dirtyMenu || dirtyNotif) && <span className="badge accent">Unsaved changes</span>}
          </div>
        </div>
        <div className="row" style={{ gap: '12px', flexWrap: 'wrap' }}>
          <button className="secondary" onClick={() => { void loadRemoteConfig(); void loadMenuSettings(); void loadNotifSettings() }} disabled={remoteConfigLoading || menuLoading || notifLoading || publishing}>
            Refresh
          </button>
          <button onClick={() => void publishChanges()} disabled={(!dirtyRemoteConfig && !dirtyMenu && !dirtyNotif) || publishing || remoteConfigLoading || menuLoading || notifLoading}>
            {publishing ? 'Publishing...' : 'Publish Changes'}
          </button>
        </div>
      </div>

      <div className="admin-layout">
        <aside className="admin-sidebar card">
          <button
            className={section === 'config' ? '' : 'secondary'}
            style={{ width: '100%', marginBottom: '8px' }}
            onClick={() => setSection('config')}
          >
            App Config
          </button>
          <button
            className={section === 'content' ? '' : 'secondary'}
            style={{ width: '100%', marginBottom: '8px' }}
            onClick={() => setSection('content')}
          >
            Content Management
          </button>
          <button
            className={section === 'menu' ? '' : 'secondary'}
            style={{ width: '100%', marginBottom: '8px' }}
            onClick={() => setSection('menu')}
          >
            Menu Settings
          </button>
          <button
            className={section === 'notifications' ? '' : 'secondary'}
            style={{ width: '100%', marginBottom: '8px' }}
            onClick={() => setSection('notifications')}
          >
            Notifications
          </button>
          <button
            className={section === 'support' ? '' : 'secondary'}
            style={{ width: '100%', marginBottom: '8px' }}
            onClick={() => setSection('support')}
          >
            Support
          </button>
        </aside>
        <main className="stack" style={{ flex: 1 }}>
          {section === 'config' && (
            <div className="stack">
              {remoteConfigError && <div className="card error-text">{remoteConfigError}</div>}
              {remoteConfigLoading ? (
                <div className="card empty-state">Loading configuration...</div>
              ) : (
                <RemoteConfigEditor
                  appConfig={remoteConfig}
                  onChange={handleRemoteConfigChange}
                  saving={publishing}
                  lastPublishedLabel={formatTimestampLabel(remoteConfig.updatedAt)}
                  updatedBy={remoteConfig.updatedBy ?? ''}
                  dirty={dirtyRemoteConfig}
                />
              )}
            </div>
          )}

          {section === 'content' && (
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
                    <div className="stack" style={{ marginTop: '20px' }}>
                      <h2 style={{ fontSize: '1.2rem' }}>All Content</h2>
                      <SortableContext items={sortedItems.map((i: ContentItem) => i.id)} strategy={verticalListSortingStrategy}>
                        <div className="grid">
                          {sortedItems.map((item: ContentItem) => (
                            <SortableItem key={item.id} item={item} onEdit={() => setEditingItem(item)} onDelete={() => handleDeleteItem(item)} />
                          ))}
                        </div>
                      </SortableContext>
                    </div>
                  </DndContext>
                </div>
              )}
            </div>
          )}
          {section === 'menu' && (
            <div className="stack">
                {menuError && <div className="card error-text">{menuError}</div>}
                {menuLoading ? (
                  <div className="card empty-state">Loading menu settings...</div>
                ) : (
                  <MenuSettingsEditor
                    settings={menuSettings}
                    onChange={handleMenuSettingsChange}
                  />
                )}
            </div>
          )}
          {section === 'notifications' && (
            <div className="stack">
              {notifError && <div className="card error-text">{notifError}</div>}
              {notifLoading ? (
                <div className="card empty-state">Loading notification settings…</div>
              ) : (
                <NotificationsEditor
                  settings={notifSettings}
                  onChange={next => { setNotifSettings(next); setDirtyNotif(true) }}
                  saving={publishing}
                  dirty={dirtyNotif}
                  lastPublishedLabel={formatTimestampLabel(notifSettings.updatedAt)}
                />
              )}
            </div>
          )}
          {section === 'support' && <SupportAdminPanel />}
        </main>
      </div>
    </div>
  )
}
