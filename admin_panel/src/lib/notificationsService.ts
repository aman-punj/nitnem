import {
  collection,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
} from 'firebase/firestore'

import { auth, db } from './firebase'
import {
  Announcement,
  DEFAULT_NOTIFICATION_SETTINGS,
  NotificationSettings,
} from './notificationsTypes'

const NOTIF_SETTINGS_DOC = doc(db, 'settings', 'notifications')
const ANNOUNCEMENTS_COL = collection(db, 'announcements')

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL as string

export async function fetchNotificationSettings(): Promise<NotificationSettings> {
  const snap = await getDoc(NOTIF_SETTINGS_DOC)
  if (!snap.exists()) return { ...DEFAULT_NOTIFICATION_SETTINGS }
  return { ...DEFAULT_NOTIFICATION_SETTINGS, ...snap.data() } as NotificationSettings
}

export async function saveNotificationSettings(
  settings: NotificationSettings,
): Promise<NotificationSettings> {
  const updated = {
    ...settings,
    updatedAt: serverTimestamp(),
    updatedBy: auth.currentUser?.email ?? 'admin',
  }
  await setDoc(NOTIF_SETTINGS_DOC, updated)
  return updated as NotificationSettings
}

export async function sendBroadcast(title: string, body: string): Promise<void> {
  const token = await auth.currentUser?.getIdToken()
  if (!token) throw new Error('Not authenticated')

  const res = await fetch(`${BACKEND_URL}/send-announcement`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ title, body, topic: 'kumnama' }),
  })

  const data = await res.json()
  if (!res.ok || !data.success) {
    throw new Error(data.error ?? 'Failed to send broadcast')
  }
}

export async function fetchRecentAnnouncements(count = 8): Promise<Announcement[]> {
  const q = query(ANNOUNCEMENTS_COL, orderBy('createdAt', 'desc'), limit(count))
  const snap = await getDocs(q)
  return snap.docs.map(d => ({ id: d.id, ...d.data() } as Announcement))
}
