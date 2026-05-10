import { initializeApp } from 'firebase/app'
import {
  GoogleAuthProvider,
  browserLocalPersistence,
  getAuth,
  onAuthStateChanged,
  setPersistence,
  signInWithPopup,
  signOut,
  type User,
} from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'

import { envConfig } from '../config/env'

const app = initializeApp(envConfig.firebase)
export const db = getFirestore(app)
export const auth = getAuth(app)

const provider = new GoogleAuthProvider()
provider.setCustomParameters({ prompt: 'select_account' })

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

export async function signInAdminWithGoogle(): Promise<User> {
  const result = await signInWithPopup(auth, provider)
  const user = result.user

  if (!isAllowedAdminEmail(user.email)) {
    await signOut(auth)
    throw new Error('Access denied: this Google account is not in the admin allowlist.')
  }

  return user
}

export async function signOutAdmin(): Promise<void> {
  await signOut(auth)
}
