import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
} from 'firebase/firestore'

import { auth, db } from './firebase'
import { DEFAULT_REMOTE_CONFIG, type RemoteConfig } from './remoteConfigTypes'

const REMOTE_CONFIG_DOCUMENT = doc(db, 'admin_config', 'remote_control')

export async function fetchRemoteConfig(): Promise<RemoteConfig> {
  const snapshot = await getDoc(REMOTE_CONFIG_DOCUMENT)
  if (!snapshot.exists()) {
    return DEFAULT_REMOTE_CONFIG
  }

  const data = snapshot.data() as RemoteConfig
  return {
    ...DEFAULT_REMOTE_CONFIG,
    ...data,
    versionControl: {
      ...DEFAULT_REMOTE_CONFIG.versionControl,
      ...data.versionControl,
    },
    maintenance: {
      ...DEFAULT_REMOTE_CONFIG.maintenance,
      ...data.maintenance,
    },
    featureFlags: {
      ...DEFAULT_REMOTE_CONFIG.featureFlags,
      ...data.featureFlags,
      languages: {
        ...DEFAULT_REMOTE_CONFIG.featureFlags.languages,
        ...(data.featureFlags?.languages ?? {}),
      },
    },
  }
}

export async function saveRemoteConfig(config: RemoteConfig): Promise<RemoteConfig> {
  const payload = {
    ...config,
    updatedAt: serverTimestamp(),
    updatedBy: auth.currentUser?.email ?? 'unknown',
  }

  await setDoc(REMOTE_CONFIG_DOCUMENT, payload, { merge: true })
  return payload as RemoteConfig
}
