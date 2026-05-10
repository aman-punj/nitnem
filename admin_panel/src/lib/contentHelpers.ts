export function slugifyTitleToId(title: string): string {
  return title
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, '_')
    .replace(/_+/g, '_')
}

export function nextTrackId(existingIds: string[]): string {
  const nums = existingIds
    .map((id) => {
      const match = id.match(/^track_(\d+)$/)
      return match ? Number(match[1]) : NaN
    })
    .filter((n) => !Number.isNaN(n))

  const next = nums.length > 0 ? Math.max(...nums) + 1 : 1
  return `track_${next}`
}

export function bumpVersion(current?: number, changed?: boolean): number {
  const existing = typeof current === 'number' && current > 0 ? current : 1
  if (!changed) return existing
  return typeof current === 'number' && current > 0 ? current + 1 : 1
}
