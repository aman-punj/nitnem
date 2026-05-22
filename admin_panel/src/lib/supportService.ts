import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore'

import { db } from './firebase'

export type SupportRequestStatus = 'new' | 'reviewed' | 'resolved'

export type SupportRequest = {
  id: string
  type: 'feedback' | 'bug'
  title: string
  message: string
  email: string
  appVersion: string
  buildNumber: string
  platform: string
  status: SupportRequestStatus
  createdAt?: any
}

export type FaqEntry = {
  id: string
  question: string
  answer: string
  order: number
  enabled: boolean
}

export type PrivacyPolicy = {
  title: string
  content: string
  updatedAt?: any
}

export async function fetchSupportRequests(): Promise<SupportRequest[]> {
  const snap = await getDocs(query(collection(db, 'support_requests'), orderBy('createdAt', 'desc')))
  return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<SupportRequest, 'id'>) }))
}

export async function updateSupportRequestStatus(id: string, status: SupportRequestStatus): Promise<void> {
  await updateDoc(doc(db, 'support_requests', id), { status })
}

export async function fetchFaqEntries(): Promise<FaqEntry[]> {
  const snap = await getDocs(query(collection(db, 'faq'), orderBy('order', 'asc')))
  return snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<FaqEntry, 'id'>) }))
}

export async function createFaqEntry(entry: Omit<FaqEntry, 'id'>): Promise<void> {
  await addDoc(collection(db, 'faq'), entry)
}

export async function updateFaqEntry(entry: FaqEntry): Promise<void> {
  await setDoc(doc(db, 'faq', entry.id), entry, { merge: true })
}

export async function deleteFaqEntry(id: string): Promise<void> {
  await deleteDoc(doc(db, 'faq', id))
}

export async function fetchPrivacyPolicy(): Promise<PrivacyPolicy> {
  const snap = await getDoc(doc(db, 'app_content', 'privacy_policy'))
  if (!snap.exists()) return { title: 'Privacy Policy', content: '' }
  return snap.data() as PrivacyPolicy
}

export async function savePrivacyPolicy(policy: Pick<PrivacyPolicy, 'title' | 'content'>): Promise<void> {
  await setDoc(
    doc(db, 'app_content', 'privacy_policy'),
    {
      ...policy,
      updatedAt: serverTimestamp(),
    },
    { merge: true },
  )
}

export type DeveloperSupport = {
  upiId: string
  upiQrUrl: string
  kofiUrl: string
  updatedAt?: any
  updatedBy?: string
}

export async function fetchDeveloperSupport(): Promise<DeveloperSupport> {
  const snap = await getDoc(doc(db, 'app_config', 'developer_support'))
  if (!snap.exists()) return { upiId: '', upiQrUrl: '', kofiUrl: '' }
  return snap.data() as DeveloperSupport
}

export async function saveDeveloperSupport(
  data: Pick<DeveloperSupport, 'upiId' | 'upiQrUrl' | 'kofiUrl'>,
  updatedBy: string,
): Promise<void> {
  await setDoc(
    doc(db, 'app_config', 'developer_support'),
    { ...data, updatedAt: serverTimestamp(), updatedBy },
    { merge: true },
  )
}
