type EnvKey =
  | 'VITE_FIREBASE_API_KEY'
  | 'VITE_FIREBASE_AUTH_DOMAIN'
  | 'VITE_FIREBASE_PROJECT_ID'
  | 'VITE_FIREBASE_STORAGE_BUCKET'
  | 'VITE_FIREBASE_MESSAGING_SENDER_ID'
  | 'VITE_FIREBASE_APP_ID'
  | 'VITE_CLOUDINARY_CLOUD_NAME'
  | 'VITE_CLOUDINARY_UPLOAD_PRESET'
  | 'VITE_ADMIN_ALLOWED_EMAILS'

const REQUIRED_KEYS: EnvKey[] = [
  'VITE_FIREBASE_API_KEY',
  'VITE_FIREBASE_AUTH_DOMAIN',
  'VITE_FIREBASE_PROJECT_ID',
  'VITE_FIREBASE_STORAGE_BUCKET',
  'VITE_FIREBASE_MESSAGING_SENDER_ID',
  'VITE_FIREBASE_APP_ID',
  'VITE_CLOUDINARY_CLOUD_NAME',
  'VITE_CLOUDINARY_UPLOAD_PRESET',
  'VITE_ADMIN_ALLOWED_EMAILS',
]

function readEnv(key: EnvKey): string {
  const value = import.meta.env[key]
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`[env] Missing required variable: ${key}`)
  }
  return value
}

function validateEnv(): void {
  const missing = REQUIRED_KEYS.filter((key) => {
    const value = import.meta.env[key]
    return typeof value !== 'string' || value.trim().length === 0
  })

  if (missing.length > 0) {
    throw new Error(
      `[env] Missing required variables: ${missing.join(', ')}. ` +
        'Create admin_panel/.env from admin_panel/.env.example and restart Vite.',
    )
  }
}

validateEnv()

function parseAllowedEmails(raw: string): string[] {
  return raw
    .split(',')
    .map((email) => email.trim().toLowerCase())
    .filter((email) => email.length > 0)
}

export type AppEnvConfig = {
  firebase: {
    apiKey: string
    authDomain: string
    projectId: string
    storageBucket: string
    messagingSenderId: string
    appId: string
  }
  cloudinary: {
    cloudName: string
    uploadPreset: string
  }
  auth: {
    allowedEmails: string[]
  }
}

export const envConfig: AppEnvConfig = {
  firebase: {
    apiKey: readEnv('VITE_FIREBASE_API_KEY'),
    authDomain: readEnv('VITE_FIREBASE_AUTH_DOMAIN'),
    projectId: readEnv('VITE_FIREBASE_PROJECT_ID'),
    storageBucket: readEnv('VITE_FIREBASE_STORAGE_BUCKET'),
    messagingSenderId: readEnv('VITE_FIREBASE_MESSAGING_SENDER_ID'),
    appId: readEnv('VITE_FIREBASE_APP_ID'),
  },
  cloudinary: {
    cloudName: readEnv('VITE_CLOUDINARY_CLOUD_NAME'),
    uploadPreset: readEnv('VITE_CLOUDINARY_UPLOAD_PRESET'),
  },
  auth: {
    allowedEmails: parseAllowedEmails(readEnv('VITE_ADMIN_ALLOWED_EMAILS')),
  },
}
