'use strict';

const express = require('express');
const admin = require('firebase-admin');
const { syncHukamnama } = require('./syncHandler');
const { sendAnnouncement } = require('./announcementHandler');
const { requireFirebaseAuth } = require('./auth');
const logger = require('./logger');

// ── Firebase Admin SDK ───────────────────────────────────────────────────────

const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT;
if (!serviceAccountJson) {
  console.error('FATAL: FIREBASE_SERVICE_ACCOUNT environment variable is not set');
  process.exit(1);
}

let serviceAccount;
try {
  serviceAccount = JSON.parse(serviceAccountJson);
} catch (err) {
  console.error('FATAL: FIREBASE_SERVICE_ACCOUNT is not valid JSON:', err.message);
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
logger.info('Firebase Admin SDK initialised', { project: serviceAccount.project_id });

// ── Express app ──────────────────────────────────────────────────────────────

const app = express();

// CORS — admin panel is hosted on a different origin (Firebase Hosting)
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, x-api-key');
  if (req.method === 'OPTIONS') return res.sendStatus(204);
  next();
});

app.use(express.json());

// ── Auth: API-key guard for machine-to-machine (GitHub Actions → /sync-hukamnama)
const SYNC_API_KEY = process.env.SYNC_API_KEY;
if (!SYNC_API_KEY) {
  logger.warn('SYNC_API_KEY is not set — /sync-hukamnama endpoint is unprotected');
}

function requireApiKey(req, res, next) {
  if (!SYNC_API_KEY) return next();
  const provided = req.headers['x-api-key'] ?? req.query.key;
  if (provided !== SYNC_API_KEY) {
    logger.warn('Unauthorized sync attempt', { ip: req.ip });
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

// ── Routes ───────────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', ts: new Date().toISOString() });
});

// Triggered by GitHub Actions cron — protected by static API key
app.post('/sync-hukamnama', requireApiKey, syncHukamnama);

// Triggered by admin panel — protected by Firebase ID token
app.post('/send-announcement', requireFirebaseAuth, sendAnnouncement);

// ── Start ────────────────────────────────────────────────────────────────────

const PORT = process.env.PORT ?? 3000;
app.listen(PORT, () => logger.info(`Server listening on port ${PORT}`));
