'use strict';

const admin = require('firebase-admin');
const logger = require('./logger');

async function sendAnnouncement(req, res) {
  const { title, body, topic = 'kumnama' } = req.body ?? {};

  if (!title?.trim() || !body?.trim()) {
    return res.status(400).json({ error: '"title" and "body" are required' });
  }

  const db = admin.firestore();

  // Write announcement record upfront so history is always visible
  const docRef = await db.collection('announcements').add({
    title: title.trim(),
    body: body.trim(),
    topic,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: req.user?.email ?? 'admin',
  });

  try {
    const message = {
      topic,
      notification: { title: title.trim(), body: body.trim() },
      android: {
        priority: 'high',
        notification: { channelId: 'nitnem_daily', sound: 'default' },
      },
      apns: {
        payload: { aps: { sound: 'default', 'content-available': 1 } },
      },
    };

    const messageId = await admin.messaging().send(message);

    await docRef.update({
      status: 'sent',
      fcmMessageId: messageId,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info('Announcement sent', { topic, messageId, title: title.trim() });
    res.json({ success: true, fcmMessageId: messageId });
  } catch (err) {
    await docRef.update({ status: 'failed', error: err.message });
    logger.error('Announcement FCM failed', { error: err.message });
    res.status(500).json({ success: false, error: err.message });
  }
}

module.exports = { sendAnnouncement };
