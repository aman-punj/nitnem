'use strict';

const admin = require('firebase-admin');
const logger = require('./logger');

/**
 * Writes hukamnama data to:
 *   hukamnama/today          — stable reference the mobile app reads
 *   hukamnama/{YYYY-MM-DD}   — historical archive
 *
 * Does NOT touch the `fcmSent` flag; that is managed by syncHandler.
 */
async function storeHukamnama(data) {
  const db = admin.firestore();
  const payload = {
    date: data.date,
    gurmukhi: data.gurmukhi,
    translationEnglish: data.translationEnglish,
    translationPunjabi: data.translationPunjabi,
    source: data.source,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Write today doc — merge:true preserves fcmSent flag set by syncHandler
  await db.collection('hukamnama').doc('today').set(payload, { merge: true });
  logger.info('Stored hukamnama/today', { date: data.date });

  // Write historical doc (full overwrite — date-keyed, no fcmSent needed)
  await db.collection('hukamnama').doc(data.date).set(payload);
  logger.info(`Stored hukamnama/${data.date}`);
}

module.exports = { storeHukamnama };
