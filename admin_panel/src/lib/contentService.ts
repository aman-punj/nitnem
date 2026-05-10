import {
  collection,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
} from 'firebase/firestore'

import { db } from './firebase'
import type { ContentItem } from './contentTypes'

const CONTENT_COLLECTION = 'content'

export async function fetchContentList(): Promise<ContentItem[]> {
  try {
    const q = query(collection(db, CONTENT_COLLECTION), orderBy('titles.en'))
    const snap = await getDocs(q)
    return snap.docs.map((item) => item.data() as ContentItem)
  } catch (_) {
    const snap = await getDocs(collection(db, CONTENT_COLLECTION))
    const list = snap.docs.map((item) => item.data() as ContentItem)
    return list.sort((a, b) => (a.titles.en || a.id).localeCompare(b.titles.en || b.id))
  }
}

export async function fetchContentById(contentId: string): Promise<ContentItem | null> {
  const snap = await getDoc(doc(db, CONTENT_COLLECTION, contentId))
  return snap.exists() ? (snap.data() as ContentItem) : null
}

export async function upsertContentItem(item: ContentItem): Promise<void> {
  await setDoc(
    doc(db, CONTENT_COLLECTION, item.id),
    {
      ...item,
      updated_at: serverTimestamp(),
    },
    { merge: true },
  )
}
