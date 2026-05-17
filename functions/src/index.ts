import * as admin from 'firebase-admin'
import { onDocumentCreated } from 'firebase-functions/v2/firestore'

admin.initializeApp()

/**
 * Triggers when admin creates a new document in `announcements/{id}`.
 * Sends a real FCM push notification to the specified topic (e.g. "kumnama"),
 * then updates the document status to 'sent' or 'failed'.
 */
export const sendAnnouncement = onDocumentCreated(
  'announcements/{id}',
  async (event) => {
    const snap = event.data
    if (!snap) return

    const data = snap.data() as {
      title: string
      body: string
      topic: string
      status: string
    }

    if (data.status !== 'pending') return

    const message: admin.messaging.Message = {
      topic: data.topic,
      notification: {
        title: data.title,
        body: data.body,
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
    }

    try {
      const response = await admin.messaging().send(message)
      await snap.ref.update({
        status: 'sent',
        fcmMessageId: response,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      })
      console.log(`Sent FCM to topic "${data.topic}", messageId: ${response}`)
    } catch (error) {
      console.error('FCM send failed:', error)
      await snap.ref.update({
        status: 'failed',
        error: String(error),
      })
    }
  },
)
