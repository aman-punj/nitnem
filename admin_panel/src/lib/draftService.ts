const DRAFT_PREFIX = 'lrc_draft:'

export type DraftData = {
  lines: Array<{ id: string; text: string; startTime: number | null }>
  activeIndex: number
  timestamp: number
  lang: string
}

/**
 * Build a localStorage key for a specific content + track + language draft.
 */
export function draftKey(contentId: string, trackId: string, lang: string): string {
  return `${DRAFT_PREFIX}${contentId}:${trackId}:${lang}`
}

/**
 * Save draft data to localStorage.
 */
export function saveDraft(key: string, data: DraftData): void {
  try {
    localStorage.setItem(key, JSON.stringify(data))
  } catch {
    // localStorage full or unavailable — silently ignore
  }
}

/**
 * Load a draft from localStorage. Returns null if missing or corrupt.
 */
export function loadDraft(key: string): DraftData | null {
  try {
    const raw = localStorage.getItem(key)
    if (!raw) return null
    const parsed = JSON.parse(raw)
    if (!parsed || !Array.isArray(parsed.lines) || typeof parsed.timestamp !== 'number') {
      return null
    }
    return parsed as DraftData
  } catch {
    return null
  }
}

/**
 * Delete a draft from localStorage.
 */
export function deleteDraft(key: string): void {
  try {
    localStorage.removeItem(key)
  } catch {
    // ignore
  }
}

/**
 * List all draft keys currently in localStorage.
 */
export function listDraftKeys(): string[] {
  const keys: string[] = []
  try {
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i)
      if (key?.startsWith(DRAFT_PREFIX)) keys.push(key)
    }
  } catch {
    // ignore
  }
  return keys
}

/**
 * Export draft data as a downloadable JSON file.
 */
export function exportDraftAsFile(key: string): void {
  const draft = loadDraft(key)
  if (!draft) return

  const exportData = {
    ...draft,
    exportedAt: new Date().toISOString(),
    key,
  }

  const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  // e.g. "lrc_draft_japji_sahib_track_1_pa_2026-07-12.json"
  const safeName = key.replace(/[^a-zA-Z0-9]/g, '_')
  a.download = `${safeName}_${new Date().toISOString().slice(0, 10)}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

/**
 * Return a human-readable "time ago" string from a timestamp.
 */
export function timeAgo(timestamp: number): string {
  const diffMs = Date.now() - timestamp
  const seconds = Math.floor(diffMs / 1000)
  if (seconds < 60) return 'just now'
  const minutes = Math.floor(seconds / 60)
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  const days = Math.floor(hours / 24)
  return `${days}d ago`
}
