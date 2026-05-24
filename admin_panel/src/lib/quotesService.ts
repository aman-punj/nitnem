import { doc, getDoc, serverTimestamp, setDoc } from 'firebase/firestore'
import { auth, db } from './firebase'

export interface Quote {
  text: string
  author?: string
}

export interface QuotesConfig {
  quotes: Quote[]
  updatedAt?: unknown
  updatedBy?: string
}

const QUOTES_DOCUMENT = doc(db, 'app_config', 'quotes')

export async function fetchQuotes(): Promise<QuotesConfig> {
  const snapshot = await getDoc(QUOTES_DOCUMENT)
  if (!snapshot.exists()) {
    return { quotes: [] }
  }
  const data = snapshot.data() as Partial<QuotesConfig>
  return {
    quotes: (data.quotes ?? []).filter((q) => q?.text?.trim()),
    updatedAt: data.updatedAt,
    updatedBy: data.updatedBy,
  }
}

export async function saveQuotes(config: QuotesConfig): Promise<QuotesConfig> {
  const payload: QuotesConfig = {
    quotes: config.quotes.map((q) => ({
      text: q.text.trim(),
      ...(q.author?.trim() ? { author: q.author.trim() } : {}),
    })),
    updatedAt: serverTimestamp(),
    updatedBy: auth.currentUser?.email ?? 'unknown',
  }
  await setDoc(QUOTES_DOCUMENT, payload)
  return payload
}
