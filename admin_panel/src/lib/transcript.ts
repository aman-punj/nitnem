export type Segment = {
  startTime: number | null
  endTime: number | null
  pa: string
  hi: string
  en: string
  flagged?: boolean
}

export type TranscriptLang = 'pa' | 'hi' | 'en'

function segmentForText(text: string, lang: TranscriptLang, startTime: number | null, endTime: number | null): Segment {
  return {
    startTime,
    endTime,
    pa: lang === 'pa' ? text : '',
    hi: lang === 'hi' ? text : '',
    en: lang === 'en' ? text : '',
  }
}

export function parseLrc(lrc: string, lang: TranscriptLang = 'pa'): Segment[] {
  const lines = lrc.split(/\r?\n/).filter(Boolean)
  const timestamped = lines
    .map((line) => {
      const m = line.match(/^\[(\d{1,3}):(\d{2}(?:\.\d{1,3})?)\](.*)$/)
      if (!m) return null
      return { start: Number(m[1]) * 60 + Number(m[2]), text: m[3].trim() }
    })
    .filter(Boolean) as { start: number; text: string }[]

  if (timestamped.length > 0) {
    return timestamped.map((entry, idx) =>
      segmentForText(entry.text, lang, entry.start, timestamped[idx + 1]?.start ?? entry.start + 6)
    )
  }

  // Fallback: treat each line as a plain text segment (Mode B/C support)
  return lines.map((line) => segmentForText(line.trim(), lang, null, null))
}
