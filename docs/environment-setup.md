# Environment Setup

This project uses Vite environment variables for the React admin panel.

## 1) Create `.env`

From the repository root:

```bash
cp admin_panel/.env.example admin_panel/.env
```

Then fill values in `admin_panel/.env`.

## 2) Required Variables

```env
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_STORAGE_BUCKET=
VITE_FIREBASE_MESSAGING_SENDER_ID=
VITE_FIREBASE_APP_ID=

VITE_CLOUDINARY_CLOUD_NAME=
VITE_CLOUDINARY_UPLOAD_PRESET=
```

## 3) Where Firebase Values Come From

Open Firebase Console:
1. Project Settings
2. General tab
3. Your apps section (Web app)
4. Copy SDK config fields into matching `VITE_FIREBASE_*` keys.

## 4) Where Cloudinary Values Come From

Open Cloudinary Console:
1. Dashboard -> copy `Cloud name`
2. Settings -> Upload -> Upload presets -> use preset name
3. Put them in:
- `VITE_CLOUDINARY_CLOUD_NAME`
- `VITE_CLOUDINARY_UPLOAD_PRESET`

## 5) Vite Env Rules

- Vite only exposes variables prefixed with `VITE_` to browser code.
- Variables without `VITE_` are not available in `import.meta.env` on client.
- After changing `.env`, restart Vite dev server.

## 6) Validation Behavior

The admin panel reads env values from `admin_panel/src/config/env.ts`.
- Missing required variables throw a clear startup error.
- No secrets are hardcoded in source.

## 7) Safety

- `admin_panel/.env` is gitignored.
- Commit only `admin_panel/.env.example` with placeholders.
