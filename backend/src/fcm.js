'use strict';

const admin = require('firebase-admin');
const logger = require('./logger');

const FCM_TOPIC = 'hukamnama';

async function sendHukamnamaNotification() {
  const message = {
    topic: FCM_TOPIC,
    notification: {
      title: 'Daily Hukamnama',
      body: "Today's Hukamnama Sahib is now available.",
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'nitnem_daily',
        sound: 'default',
      },
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          'content-available': 1,
        },
      },
    },
  };

  const messageId = await admin.messaging().send(message);
  logger.info('FCM notification sent', { topic: FCM_TOPIC, messageId });
  return messageId;
}

module.exports = { sendHukamnamaNotification };
