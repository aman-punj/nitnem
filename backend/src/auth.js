'use strict';

const admin = require('firebase-admin');
const logger = require('./logger');

async function requireFirebaseAuth(req, res, next) {
  const header = req.headers.authorization ?? '';
  if (!header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing Authorization header' });
  }
  try {
    req.user = await admin.auth().verifyIdToken(header.slice(7));
    next();
  } catch (err) {
    logger.warn('Firebase auth verification failed', { error: err.message });
    res.status(401).json({ error: 'Invalid or expired token' });
  }
}

module.exports = { requireFirebaseAuth };
