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
  displayOrder: number
  updated_at?: unknown
}

export type YoutubeLiveContentData = {
  id: string
  type: 'youtube_live'
  titles: LocalizedTitles
  youtube_url: string
  enabled: boolean
  thumbnail?: string
  categoryId?: string
  displayOrder: number
  updated_at?: unknown
}

export type ContentItem = PrayerContentData | YoutubeLiveContentData

export function contentDisplayTitle(item: ContentItem): string {
  return item.titles.en || item.id
}
