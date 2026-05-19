'use strict';

const admin = require('firebase-admin');
const { fetchHukamnama } = require('./hukamnamaFetcher');
const { storeHukamnama } = require('./firestore');
const { sendHukamnamaNotification } = require('./fcm');
const logger = require('./logger');

async function syncHukamnama(req, res) {
  const start = Date.now();
  logger.info('Hukamnama sync started');

  try {
    const data = await fetchHukamnama();
    logger.info('Hukamnama fetched', { date: data.date });

    // Idempotency guard: if FCM was already sent for today, skip notification.
    // This makes the endpoint safe to retry (GitHub Actions cold-start timeouts).
    const db = admin.firestore();
    const todayDoc = await db.collection('hukamnama').doc('today').get();
    const fcmAlreadySent =
      todayDoc.exists &&
      todayDoc.data()?.date === data.date &&
      todayDoc.data()?.fcmSent === true;

    // Always write Firestore (idempotent content update)
    await storeHukamnama(data);

    let fcmMessageId = null;
    if (!fcmAlreadySent) {
      fcmMessageId = await sendHukamnamaNotification();
      // Persist sent flag so retries don't double-notify
      await db
        .collection('hukamnama')
        .doc('today')
        .update({ fcmSent: true, fcmSentAt: admin.firestore.FieldValue.serverTimestamp() });
    } else {
      logger.info('FCM already sent for today, skipping', { date: data.date });
    }

    const duration = Date.now() - start;
    logger.info('Hukamnama sync completed', { date: data.date, duration, fcmAlreadySent });

    res.json({
      success: true,
      date: data.date,
      fcmMessageId,
      fcmAlreadySent,
      durationMs: duration,
    });
  } catch (err) {
    const duration = Date.now() - start;
    logger.error('Hukamnama sync failed', { error: err.message, duration });
    res.status(500).json({ success: false, error: err.message });
  }
}

module.exports = { syncHukamnama };
