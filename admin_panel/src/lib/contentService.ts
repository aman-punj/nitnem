import {
  collection,
  deleteDoc,
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
    
    // Sort by displayOrder only (ascending)
    items.sort((a, b) => {
      return (a.displayOrder ?? 0) - (b.displayOrder ?? 0)
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

export async function deleteContentItem(contentId: string): Promise<void> {
  await deleteDoc(doc(db, CONTENT_COLLECTION, contentId))
}
