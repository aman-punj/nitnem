import { initializeApp } from 'firebase/app'
import {
  browserLocalPersistence,
  getAuth,
  onAuthStateChanged,
  setPersistence,
  signInWithEmailAndPassword,
  signOut,
  type User,
} from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'

import { envConfig } from '../config/env'

const app = initializeApp(envConfig.firebase)
export const db = getFirestore(app)
export const auth = getAuth(app)

export function isAllowedAdminEmail(email: string | null | undefined): boolean {
  if (!email) return false
  return envConfig.auth.allowedEmails.includes(email.toLowerCase())
}

export async function initAuthPersistence(): Promise<void> {
  await setPersistence(auth, browserLocalPersistence)
}

export function onAdminAuthChange(callback: (user: User | null) => void): () => void {
  return onAuthStateChanged(auth, callback)
}

export async function signInAdmin(email: string, password: string): Promise<User> {
  await initAuthPersistence()
  const result = await signInWithEmailAndPassword(auth, email, password)

  if (!isAllowedAdminEmail(result.user.email)) {
    await signOut(auth)
    throw new Error('Access denied: this account is not in the admin allowlist.')
  }

  return result.user
}

export async function signOutAdmin(): Promise<void> {
  await signOut(auth)
}
