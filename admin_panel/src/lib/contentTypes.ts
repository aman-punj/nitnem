export type ContentType = 'prayer' | 'youtube_live'

export type PrayerTrack = {
  audio_url?: string
  pa_url?: string
  hi_url?: string
  en_url?: string
  audio_version?: number
  lyrics_version?: number
  duration?: number
}

export type PrayerContentData = {
  id: string
  type: 'prayer'
  title: string
  enabled: boolean
  active_track: string
  tracks: Record<string, PrayerTrack>
  updated_at?: unknown
}

export type YoutubeLiveContentData = {
  id: string
  type: 'youtube_live'
  title: string
  subtitle?: string
  youtube_url: string
  thumbnail?: string
  enabled: boolean
  updated_at?: unknown
}

export type ContentItem = PrayerContentData | YoutubeLiveContentData
