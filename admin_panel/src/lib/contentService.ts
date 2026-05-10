import {
  collection,
  doc,
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
  const q = query(collection(db, CONTENT_COLLECTION), orderBy('title'))
  const snap = await getDocs(q)
  return snap.docs.map((item) => item.data() as ContentItem)
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
