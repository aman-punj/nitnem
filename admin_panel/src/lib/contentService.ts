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
    const snap = await getDocs(collection(db, CONTENT_COLLECTION))
    const items = snap.docs.map((item) => item.data() as ContentItem)
    
    // Multi-criteria sort (matching mobile app logic)
    items.sort((a, b) => {
      // 1. pinToTop
      if (a.pinToTop !== b.pinToTop) {
        return a.pinToTop ? -1 : 1
      }

      // 2. displayOrder
      if (a.displayOrder !== b.displayOrder) {
        return a.displayOrder - b.displayOrder
      }

      // 3. Type priority (Prayer > YouTube)
      if (a.type !== b.type) {
        return a.type === 'prayer' ? -1 : 1
      }

      // 4. Alphabetical fallback
      return (a.titles.en || '').localeCompare(b.titles.en || '')
    })
    
    return items
  } catch (err) {
    console.error('Error fetching content list:', err)
    return []
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
