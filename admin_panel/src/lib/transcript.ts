export type Segment = {
  start: number
  end: number
  pa: string
  hi: string
  en: string
  flagged?: boolean
}

export function parseLrc(lrc: string): Segment[] {
  const lines = lrc.split(/\r?\n/).filter(Boolean)
  const parsed = lines
    .map((line) => {
      const m = line.match(/^\[(\d{2}):(\d{2}\.\d{1,3})\](.*)$/)
      if (!m) return null
      return { start: Number(m[1]) * 60 + Number(m[2]), text: m[3].trim() }
    })
    .filter(Boolean) as { start: number; text: string }[]

  return parsed.map((entry, idx) => ({
    start: entry.start,
    end: parsed[idx + 1]?.start ?? entry.start + 6,
    pa: entry.text,
    hi: '',
    en: '',
  }))
}
