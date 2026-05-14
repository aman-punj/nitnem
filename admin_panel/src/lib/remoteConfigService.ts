import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
} from 'firebase/firestore'

import { auth, db } from './firebase'
import { DEFAULT_REMOTE_CONFIG, type RemoteConfig } from './remoteConfigTypes'

const REMOTE_CONFIG_DOCUMENT = doc(db, 'app_config', 'mobile')

export async function fetchRemoteConfig(): Promise<RemoteConfig> {
  const snapshot = await getDoc(REMOTE_CONFIG_DOCUMENT)
  if (!snapshot.exists()) {
    return DEFAULT_REMOTE_CONFIG
  }

  const data = snapshot.data() as Partial<RemoteConfig>
  return {
    ...DEFAULT_REMOTE_CONFIG,
    ...data,
    versions: {
      ...DEFAULT_REMOTE_CONFIG.versions,
      ...(data.versions ?? {}),
    },
    messages: {
      ...DEFAULT_REMOTE_CONFIG.messages,
      ...(data.messages ?? {}),
      minorUpdate: {
        ...DEFAULT_REMOTE_CONFIG.messages.minorUpdate,
        ...(data.messages?.minorUpdate ?? {}),
      },
      forceUpdate: {
        ...DEFAULT_REMOTE_CONFIG.messages.forceUpdate,
        ...(data.messages?.forceUpdate ?? {}),
      },
      maintenance: {
        ...DEFAULT_REMOTE_CONFIG.messages.maintenance,
        ...(data.messages?.maintenance ?? {}),
      },
    },
    maintenance: {
      ...DEFAULT_REMOTE_CONFIG.maintenance,
      ...(data.maintenance ?? {}),
    },
    storeUrl: {
      ...DEFAULT_REMOTE_CONFIG.storeUrl,
      ...(data.storeUrl ?? {}),
    },
  }
}

export async function saveRemoteConfig(config: RemoteConfig): Promise<RemoteConfig> {
  // Enforce strict schema: only keep the allowed fields
  const payload: RemoteConfig = {
    versions: config.versions,
    messages: config.messages,
    maintenance: config.maintenance,
    storeUrl: config.storeUrl,
    updatedAt: serverTimestamp(),
    updatedBy: auth.currentUser?.email ?? 'unknown',
  }

  // Use setDoc without merge: true to fully replace the document
  await setDoc(REMOTE_CONFIG_DOCUMENT, payload)
  return payload
}
