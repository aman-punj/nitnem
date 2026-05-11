export type ContentType = 'prayer' | 'youtube_live'

export type LocalizedTitles = {
  en: string
  pa: string
  hi: string
}

export type VersionedFile = {
  url: string
  version: number
}

export type PrayerTrack = {
  id: string
  title: string
  audio?: VersionedFile
  transcripts: {
    pa?: VersionedFile
    hi?: VersionedFile
    en?: VersionedFile
  }
  duration?: number
}

export type PrayerContentData = {
  id: string
  type: 'prayer'
  titles: LocalizedTitles
  enabled: boolean
  active_track: string
  tracks: Record<string, PrayerTrack>
  categoryId?: string
  updated_at?: unknown
  // Phase 2
  displayOrder: number
  pinToTop: boolean
  contentPriorityType: 'high' | 'normal' | 'low'
}

export type YoutubeLiveContentData = {
  id: string
  type: 'youtube_live'
  titles: LocalizedTitles
  youtube_url: string
  enabled: boolean
  thumbnail?: string
  categoryId?: string
  updated_at?: unknown
  // Phase 2
  displayOrder: number
  pinToTop: boolean
  contentPriorityType: 'high' | 'normal' | 'low'
}

export type ContentItem = PrayerContentData | YoutubeLiveContentData

export function contentDisplayTitle(item: ContentItem): string {
  return item.titles.en || item.id
}
