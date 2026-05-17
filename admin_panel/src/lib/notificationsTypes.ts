export interface NotificationSettings {
  morning_time: string     // "HH:MM"
  morning_message: string
  evening_time: string     // "HH:MM"
  evening_message: string
  updatedAt?: unknown
  updatedBy?: string
}

export interface Announcement {
  id: string
  title: string
  body: string
  topic: string
  status: 'pending' | 'sent' | 'failed'
  createdAt?: unknown
  createdBy?: string
}

export const DEFAULT_NOTIFICATION_SETTINGS: NotificationSettings = {
  morning_time: '06:00',
  morning_message: 'Time for your morning Nitnem',
  evening_time: '18:30',
  evening_message: 'Time for your evening Nitnem',
}
