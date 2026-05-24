import { useState, useRef, useEffect, useCallback, useMemo } from 'react'

// ── Types ──────────────────────────────────────────────────────────────────────

type Line = {
  id: string
  text: string
  startTime: number | null
}

type Props = {
  audioFile: File | null
  audioUrl?: string
  initialLrc: string
  lang: 'pa' | 'hi' | 'en'
  onClose: () => void
  onSave: (lrc: string) => void
}

// ── Utilities ──────────────────────────────────────────────────────────────────

function uid() {
  return Math.random().toString(36).slice(2, 9)
}

function fmtTime(s: number): string {
  if (!isFinite(s) || isNaN(s) || s < 0) return '--:--.--'
  const m = Math.floor(s / 60)
  const secs = (s % 60).toFixed(2).padStart(5, '0')
  return `${String(m).padStart(2, '0')}:${secs}`
}

function parseTime(str: string): number | null {
  const s = str.trim()
  if (!s) return null
  // MM:SS.ss or M:SS.ss
  const m1 = s.match(/^(\d+):(\d{1,2}(?:\.\d{1,3})?)$/)
  if (m1) {
    const t = Number(m1[1]) * 60 + Number(m1[2])
    return isFinite(t) ? t : null
  }
  // Raw seconds
  const m2 = s.match(/^(\d+(?:\.\d{1,3})?)$/)
  if (m2) {
    const t = Number(m2[1])
    return isFinite(t) ? t : null
  }
  return null
}

function parseLrcOrPlain(raw: string): Line[] {
  return raw
    .split(/\r?\n/)
    .filter(l => l.trim())
    .map(line => {
      const m = line.match(/^\[(\d{1,3}):(\d{2}\.\d{1,3})\](.*)$/)
      if (m) {
        const t = Number(m[1]) * 60 + Number(m[2])
        if (isFinite(t) && !isNaN(t)) {
          return { id: uid(), text: m[3].trim(), startTime: t }
        }
      }
      // Strip any malformed [...] prefix (e.g. legacy [NaN:00NaN] data)
      const text = line.replace(/^\[[^\]]*\]/, '').trim() || line.trim()
      return { id: uid(), text, startTime: null }
    })
}

// Full LRC — only timed lines, used for standard .lrc export
function toLrc(lines: Line[]): string {
  return lines
    .filter(l => l.text.trim() && l.startTime !== null)
    .map(l => `[${fmtTime(l.startTime!)}]${l.text}`)
    .join('\n')
}

// Mixed format — timed lines get [MM:SS.ss] prefix, untimed are plain text.
// Used for Save so untimed (plain) lyrics are never silently dropped.
function toMixedLrc(lines: Line[]): string {
  return lines
    .filter(l => l.text.trim())
    .map(l => l.startTime !== null ? `[${fmtTime(l.startTime!)}]${l.text}` : l.text)
    .join('\n')
}

function triggerDownload(content: string, filename: string) {
  const blob = new Blob([content], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

const LANG_NAMES: Record<string, string> = { pa: 'Punjabi', hi: 'Hindi', en: 'English' }

// ── Shared style constants ─────────────────────────────────────────────────────

const S = {
  border: '1px solid #1e1e1e',
  borderDim: '1px solid #141414',
  inputBase: {
    background: '#181818',
    color: '#ccc',
    border: '1px solid #2a2a2a',
    borderRadius: '4px',
    padding: '4px 8px',
    fontSize: '0.82rem',
    outline: 'none',
  } as React.CSSProperties,
  monoSm: { fontFamily: 'monospace', fontSize: '0.8rem' } as React.CSSProperties,
}

// ── Component ──────────────────────────────────────────────────────────────────

export function LrcStudio({ audioFile, audioUrl, initialLrc, lang, onClose, onSave }: Props) {
  const audioRef = useRef<HTMLAudioElement>(null)
  const listRef = useRef<HTMLDivElement>(null)
  const isRecordingRef = useRef(false)   // stale-closure-safe ref

  // ── Lines ────────────────────────────────────────────────────────────────────
  const [lines, setLines] = useState<Line[]>(() => parseLrcOrPlain(initialLrc || ''))
  const [activeIndex, setActiveIndex] = useState(0)
  const [dirty, setDirty] = useState(false)

  // ── Audio ────────────────────────────────────────────────────────────────────
  const [blobUrl, setBlobUrl] = useState<string | null>(null)
  const [currentTime, setCurrentTime] = useState(0)
  const [duration, setDuration] = useState(0)
  const [isPlaying, setIsPlaying] = useState(false)
  const [playbackRate, setPlaybackRate] = useState(1)
  const [audioError, setAudioError] = useState<string | null>(null)

  // ── Modes ────────────────────────────────────────────────────────────────────
  const [isRecording, setIsRecording] = useState(false)
  const [showImport, setShowImport] = useState(!initialLrc.trim())
  const [importText, setImportText] = useState(initialLrc)

  // ── Search & range filter ────────────────────────────────────────────────────
  const [searchQuery, setSearchQuery] = useState('')
  const [rangeStartStr, setRangeStartStr] = useState('')
  const [rangeEndStr, setRangeEndStr] = useState('')
  const [rangeActive, setRangeActive] = useState(false)

  // ── Timestamp inline editor ──────────────────────────────────────────────────
  const [editTsId, setEditTsId] = useState<string | null>(null)
  const [editTsDraft, setEditTsDraft] = useState('')

  // Keep isRecordingRef in sync for use inside stale closures
  useEffect(() => { isRecordingRef.current = isRecording }, [isRecording])

  // ── Blob URL for uploaded files ───────────────────────────────────────────────
  useEffect(() => {
    if (!audioFile) return
    const url = URL.createObjectURL(audioFile)
    setBlobUrl(url)
    return () => URL.revokeObjectURL(url)
  }, [audioFile])

  const audioSrc = blobUrl ?? audioUrl ?? ''

  // ── Audio events ──────────────────────────────────────────────────────────────
  useEffect(() => {
    const audio = audioRef.current
    if (!audio) return
    setAudioError(null)

    const onTime = () => setCurrentTime(audio.currentTime)
    const onDuration = () => {
      const d = audio.duration
      if (isFinite(d) && !isNaN(d)) setDuration(d)
    }
    const onPlay = () => setIsPlaying(true)
    const onPause = () => setIsPlaying(false)
    const onEnded = () => {
      setIsPlaying(false)
      if (isRecordingRef.current) setIsRecording(false)
    }
    const onError = () => {
      const msgs: Record<number, string> = {
        1: 'Playback aborted',
        2: 'Network error loading audio',
        3: 'Audio decode error',
        4: 'Audio format not supported',
      }
      setAudioError(msgs[audio.error?.code ?? 0] ?? 'Failed to load audio')
    }

    audio.addEventListener('timeupdate', onTime)
    audio.addEventListener('loadedmetadata', onDuration)
    audio.addEventListener('durationchange', onDuration)
    audio.addEventListener('play', onPlay)
    audio.addEventListener('pause', onPause)
    audio.addEventListener('ended', onEnded)
    audio.addEventListener('error', onError)
    if (audio.readyState === 0 && audio.src) audio.load()

    return () => {
      audio.removeEventListener('timeupdate', onTime)
      audio.removeEventListener('loadedmetadata', onDuration)
      audio.removeEventListener('durationchange', onDuration)
      audio.removeEventListener('play', onPlay)
      audio.removeEventListener('pause', onPause)
      audio.removeEventListener('ended', onEnded)
      audio.removeEventListener('error', onError)
    }
  }, [audioSrc])

  useEffect(() => {
    if (audioRef.current) audioRef.current.playbackRate = playbackRate
  }, [playbackRate])

  // ── Playing line (which line the audio is currently at) ───────────────────────
  const playingIndex = useMemo(() => {
    let result = -1
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].startTime !== null && lines[i].startTime! <= currentTime) result = i
    }
    return result
  }, [lines, currentTime])

  // ── Auto-scroll: cursor (recording) ───────────────────────────────────────────
  useEffect(() => {
    const el = listRef.current?.querySelector('[data-cursor="1"]') as HTMLElement | null
    el?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }, [activeIndex])

  // ── Auto-scroll: playing line (only during playback, not when user is recording)
  useEffect(() => {
    if (!isPlaying || isRecording) return
    const el = listRef.current?.querySelector('[data-playing="1"]') as HTMLElement | null
    el?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }, [playingIndex, isPlaying, isRecording])

  // ── Stamp: capture current time to cursor line ────────────────────────────────
  const stamp = useCallback(() => {
    const audio = audioRef.current
    if (!audio) return
    const t = audio.currentTime
    setLines(prev => {
      const next = [...prev]
      if (activeIndex >= 0 && activeIndex < next.length) {
        next[activeIndex] = { ...next[activeIndex], startTime: t }
      }
      return next
    })
    setDirty(true)
    setActiveIndex(prev => Math.min(prev + 1, lines.length - 1))
  }, [activeIndex, lines.length])

  // ── Keyboard shortcuts ─────────────────────────────────────────────────────────
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (showImport) return
      const target = e.target as HTMLElement
      const isInputFocused = target.tagName === 'INPUT' || target.tagName === 'TEXTAREA'
      const audio = audioRef.current
      if (!audio) return

      // Space: stamp in recording mode, else play/pause
      if (e.code === 'Space' && !isInputFocused) {
        e.preventDefault()
        isRecording ? stamp() : (audio.paused ? audio.play().catch(() => {}) : audio.pause())
        return
      }

      if (isInputFocused) return

      if (e.code === 'Backspace' && isRecording) {
        e.preventDefault()
        setActiveIndex(prev => Math.max(prev - 1, 0))
      }
      if (e.key === 'Escape') {
        e.preventDefault()
        if (isRecording) setIsRecording(false)
        else if (editTsId) setEditTsId(null)
      }
      if (e.code === 'ArrowLeft') {
        e.preventDefault()
        audio.currentTime = Math.max(0, audio.currentTime - (e.shiftKey ? 5 : e.ctrlKey ? 0.5 : 2))
      }
      if (e.code === 'ArrowRight') {
        e.preventDefault()
        audio.currentTime = Math.min(duration, audio.currentTime + (e.shiftKey ? 5 : e.ctrlKey ? 0.5 : 2))
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [stamp, isRecording, showImport, editTsId, duration])

  // ── Audio control helpers ──────────────────────────────────────────────────────
  const seek = useCallback((t: number) => {
    if (audioRef.current) audioRef.current.currentTime = Math.max(0, Math.min(t, duration || Infinity))
  }, [duration])

  const seekAndPlay = useCallback((t: number) => {
    seek(t)
    audioRef.current?.play().catch(() => {})
  }, [seek])

  const handleSeekBar = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!audioRef.current || duration === 0) return
    const rect = e.currentTarget.getBoundingClientRect()
    seek(((e.clientX - rect.left) / rect.width) * duration)
  }

  const togglePlay = () => {
    const audio = audioRef.current
    if (!audio) return
    audio.paused ? audio.play().catch(() => {}) : audio.pause()
  }

  const stop = () => {
    if (!audioRef.current) return
    audioRef.current.pause()
    audioRef.current.currentTime = 0
  }

  // ── Line mutations ─────────────────────────────────────────────────────────────
  const mutLines = (fn: (prev: Line[]) => Line[]) => {
    setLines(fn)
    setDirty(true)
  }

  const updateLine = (id: string, patch: Partial<Line>) =>
    mutLines(prev => prev.map(l => l.id === id ? { ...l, ...patch } : l))

  const addLineAfter = (afterIndex: number) => {
    mutLines(prev => {
      const next = [...prev]
      next.splice(afterIndex + 1, 0, { id: uid(), text: '', startTime: null })
      return next
    })
    setActiveIndex(afterIndex + 1)
  }

  const deleteLine = (i: number) => {
    mutLines(prev => prev.filter((_, idx) => idx !== i))
    setActiveIndex(prev => Math.max(0, Math.min(prev, lines.length - 2)))
  }

  const moveLine = (i: number, dir: -1 | 1) => {
    const j = i + dir
    if (j < 0 || j >= lines.length) return
    mutLines(prev => {
      const next = [...prev]
      ;[next[i], next[j]] = [next[j], next[i]]
      return next
    })
    setActiveIndex(j)
  }

  // ── Timestamp inline editor ────────────────────────────────────────────────────
  const openTsEdit = (e: React.MouseEvent, line: Line) => {
    e.stopPropagation()
    setEditTsId(line.id)
    setEditTsDraft(line.startTime !== null ? fmtTime(line.startTime) : '')
  }

  const commitTsEdit = (lineId: string) => {
    const t = parseTime(editTsDraft)
    updateLine(lineId, { startTime: t })
    setEditTsId(null)
  }

  // ── Row interactions ───────────────────────────────────────────────────────────
  const handleRowClick = (index: number) => setActiveIndex(index)

  const handleRowDoubleClick = (e: React.MouseEvent, line: Line, index: number) => {
    // Don't hijack double-click inside text inputs (e.g. word selection)
    if ((e.target as HTMLElement).tagName === 'INPUT') return
    setActiveIndex(index)
    if (line.startTime !== null) seekAndPlay(line.startTime)
  }

  // ── Recording toggle ───────────────────────────────────────────────────────────
  const toggleRecording = () => {
    if (!isRecording) {
      setIsRecording(true)
      if (audioRef.current?.paused) audioRef.current?.play().catch(() => {})
    } else {
      setIsRecording(false)
    }
  }

  // ── Import ─────────────────────────────────────────────────────────────────────
  const applyImport = () => {
    if (!importText.trim()) return
    mutLines(() => parseLrcOrPlain(importText))
    setActiveIndex(0)
    setShowImport(false)
  }

  // ── Save / Export ──────────────────────────────────────────────────────────────
  const handleSave = () => {
    onSave(toMixedLrc(lines))
    setDirty(false)
    onClose()
  }

  const handleExportLrc = () => triggerDownload(toLrc(lines), `lyrics_${lang}.lrc`)

  // ── Derived values ─────────────────────────────────────────────────────────────
  const timedCount = useMemo(() => lines.filter(l => l.startTime !== null).length, [lines])
  const progressPercent = duration > 0 ? (currentTime / duration) * 100 : 0

  const rangeStartSec = useMemo(() => rangeActive ? (parseTime(rangeStartStr) ?? 0) : null, [rangeActive, rangeStartStr])
  const rangeEndSec = useMemo(() => rangeActive ? (parseTime(rangeEndStr) ?? Infinity) : null, [rangeActive, rangeEndStr])

  const displayLines = useMemo(() =>
    lines.map((line, index) => {
      const matchesSearch = searchQuery
        ? line.text.toLowerCase().includes(searchQuery.toLowerCase())
        : false
      const inRange = rangeActive && rangeStartSec !== null && rangeEndSec !== null
        ? (line.startTime !== null && line.startTime >= rangeStartSec && line.startTime <= rangeEndSec)
        : true
      return { line, index, matchesSearch, inRange }
    }),
    [lines, searchQuery, rangeActive, rangeStartSec, rangeEndSec]
  )

  const visibleCount = useMemo(() => displayLines.filter(d => d.inRange).length, [displayLines])

  // ── Render ─────────────────────────────────────────────────────────────────────
  return (
    <div style={{
      position: 'fixed', inset: 0, zIndex: 1000,
      background: '#080808', display: 'flex', flexDirection: 'column',
      fontFamily: 'inherit', color: '#ccc',
    }}>
      {audioSrc && (
        <audio ref={audioRef} src={audioSrc} preload="metadata" crossOrigin="anonymous" style={{ display: 'none' }} />
      )}

      {/* ════════════════════════════════════════════════════════════════
          HEADER
      ════════════════════════════════════════════════════════════════ */}
      <div style={{
        background: '#0c0c0c', borderBottom: S.border,
        padding: '10px 20px', display: 'flex', alignItems: 'center',
        justifyContent: 'space-between', flexShrink: 0, gap: '12px',
      }}>
        {/* Left: title + badges */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', minWidth: 0 }}>
          <span style={{ color: '#fff', fontWeight: 700, fontSize: '0.95rem', whiteSpace: 'nowrap' }}>
            Timing Studio
          </span>
          <span style={{
            background: '#0e1e2e', color: '#4488bb', padding: '2px 8px',
            borderRadius: '4px', fontSize: '0.72rem', fontWeight: 600, whiteSpace: 'nowrap',
          }}>
            {LANG_NAMES[lang]}
          </span>
          {isRecording && (
            <span style={{
              background: '#2a0808', color: '#ff5555', padding: '2px 8px',
              borderRadius: '4px', fontSize: '0.72rem', fontWeight: 700, whiteSpace: 'nowrap',
              border: '1px solid #5a1010',
            }}>
              ⏺ RECORDING — Space to stamp · Backspace to go back · Esc to stop
            </span>
          )}
          <span style={{ color: '#2e2e2e', fontSize: '0.75rem', whiteSpace: 'nowrap' }}>
            {timedCount} / {lines.length} timed
            {dirty && <span style={{ color: '#444', marginLeft: 8 }}>● unsaved</span>}
          </span>
        </div>

        {/* Right: action buttons */}
        <div style={{ display: 'flex', gap: '6px', flexShrink: 0, alignItems: 'center' }}>
          <button
            className="secondary"
            style={{ fontSize: '0.78rem', padding: '5px 12px' }}
            onClick={() => setShowImport(v => !v)}
          >
            {showImport ? 'Hide Import' : '↑ Import'}
          </button>
          <button
            className="secondary"
            style={{ fontSize: '0.78rem', padding: '5px 12px' }}
            onClick={handleExportLrc}
            disabled={timedCount === 0}
          >
            ↓ Export LRC
          </button>
          <button
            style={{ padding: '5px 18px', fontSize: '0.88rem' }}
            onClick={handleSave}
            disabled={lines.length === 0}
          >
            Save{dirty ? ' *' : ''}
          </button>
          <button className="secondary" style={{ padding: '5px 10px', fontSize: '0.88rem' }} onClick={onClose}>
            ✕
          </button>
        </div>
      </div>

      {/* ════════════════════════════════════════════════════════════════
          TRANSPORT
      ════════════════════════════════════════════════════════════════ */}
      <div style={{
        background: '#0f0f0f', borderBottom: S.border,
        padding: '10px 20px', flexShrink: 0,
      }}>
        {!audioSrc ? (
          <p style={{ color: '#333', fontSize: '0.85rem', margin: 0 }}>
            No audio loaded — upload audio in the track editor first, then re-open this studio.
          </p>
        ) : audioError ? (
          <p style={{ color: '#cc4444', fontSize: '0.85rem', margin: 0 }}>
            ⚠ {audioError}
          </p>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
            {/* Playback controls */}
            <button
              className="secondary"
              title="Stop (return to start)"
              style={{ padding: '6px 10px', fontSize: '0.85rem', flexShrink: 0 }}
              onClick={stop}
            >
              ■
            </button>
            <button
              className="secondary"
              title="Skip back 5 seconds"
              style={{ padding: '6px 10px', fontSize: '0.8rem', flexShrink: 0 }}
              onClick={() => seek(currentTime - 5)}
            >
              −5s
            </button>
            <button
              title={isPlaying ? 'Pause' : 'Play'}
              style={{ minWidth: '86px', padding: '6px 12px', flexShrink: 0 }}
              onClick={togglePlay}
            >
              {isPlaying ? '⏸ Pause' : '▶ Play'}
            </button>
            <button
              className="secondary"
              title="Skip forward 5 seconds"
              style={{ padding: '6px 10px', fontSize: '0.8rem', flexShrink: 0 }}
              onClick={() => seek(currentTime + 5)}
            >
              +5s
            </button>

            {/* Current time */}
            <span style={{ ...S.monoSm, color: '#bbb', minWidth: '68px', flexShrink: 0 }}>
              {fmtTime(currentTime)}
            </span>

            {/* Seek bar */}
            <div
              onClick={handleSeekBar}
              title="Click to seek"
              style={{
                flex: 1, minWidth: '80px', height: '6px',
                background: '#1e1e1e', borderRadius: '3px',
                cursor: 'pointer', position: 'relative',
              }}
            >
              <div style={{
                position: 'absolute', left: 0, top: 0, bottom: 0,
                width: `${progressPercent}%`,
                background: 'var(--accent, #4455cc)', borderRadius: '3px',
                transition: 'width 0.1s linear',
              }} />
            </div>

            {/* Duration */}
            <span style={{ ...S.monoSm, color: '#444', minWidth: '68px', flexShrink: 0 }}>
              {fmtTime(duration)}
            </span>

            {/* Speed */}
            <div style={{ display: 'flex', gap: '2px', flexShrink: 0 }}>
              {[0.5, 0.75, 1, 1.25].map(r => (
                <button
                  key={r}
                  className={playbackRate === r ? '' : 'secondary'}
                  style={{ padding: '4px 7px', fontSize: '0.72rem' }}
                  onClick={() => setPlaybackRate(r)}
                >
                  {r}×
                </button>
              ))}
            </div>

            {/* Divider */}
            <div style={{ width: '1px', height: '20px', background: '#1e1e1e', flexShrink: 0 }} />

            {/* Record mode toggle */}
            <button
              title={isRecording
                ? 'Stop recording mode'
                : 'Recording mode: Space stamps the current time to the selected line and advances'}
              style={{
                padding: '6px 14px', flexShrink: 0,
                background: isRecording ? '#3a0a0a' : undefined,
                borderColor: isRecording ? '#882222' : undefined,
                color: isRecording ? '#ff6666' : undefined,
              }}
              onClick={toggleRecording}
            >
              {isRecording ? '⏹ Stop Rec' : '⏺ Record'}
            </button>
          </div>
        )}
      </div>

      {/* ════════════════════════════════════════════════════════════════
          TOOLBAR — search + range filter
      ════════════════════════════════════════════════════════════════ */}
      <div style={{
        background: '#0a0a0a', borderBottom: S.borderDim,
        padding: '7px 20px', flexShrink: 0,
        display: 'flex', gap: '12px', alignItems: 'center', flexWrap: 'wrap',
      }}>
        {/* Search */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <span style={{ color: '#333', fontSize: '0.8rem' }}>🔍</span>
          <input
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder="Search lyrics…"
            style={{ ...S.inputBase, width: '180px' }}
          />
          {searchQuery && (
            <button className="secondary" style={{ padding: '2px 7px', fontSize: '0.72rem' }} onClick={() => setSearchQuery('')}>
              ×
            </button>
          )}
        </div>

        <div style={{ width: '1px', height: '18px', background: '#1a1a1a' }} />

        {/* Time range filter */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '5px' }}>
          <span style={{ color: '#333', fontSize: '0.78rem', flexShrink: 0 }}>Range:</span>
          <input
            value={rangeStartStr}
            onChange={e => setRangeStartStr(e.target.value)}
            placeholder="00:00"
            style={{ ...S.inputBase, ...S.monoSm, width: '68px' }}
          />
          <span style={{ color: '#2a2a2a', fontSize: '0.8rem' }}>→</span>
          <input
            value={rangeEndStr}
            onChange={e => setRangeEndStr(e.target.value)}
            placeholder="00:00"
            style={{ ...S.inputBase, ...S.monoSm, width: '68px' }}
          />
          <button
            style={{ padding: '4px 10px', fontSize: '0.75rem' }}
            disabled={!rangeStartStr || !rangeEndStr}
            onClick={() => setRangeActive(true)}
          >
            Apply
          </button>
          {rangeActive && (
            <>
              <button
                className="secondary"
                style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                onClick={() => { setRangeActive(false); setRangeStartStr(''); setRangeEndStr('') }}
              >
                Clear
              </button>
              <span style={{ color: '#3a6a3a', fontSize: '0.75rem' }}>
                {visibleCount} lines in range
              </span>
            </>
          )}
        </div>

        {/* Shortcut hint when not recording */}
        {!isRecording && (
          <span style={{ color: '#222', fontSize: '0.72rem', marginLeft: 'auto' }}>
            Double-click line → seek &amp; play · Click timestamp → edit · ← → seek · Shift ±5s
          </span>
        )}
      </div>

      {/* ════════════════════════════════════════════════════════════════
          IMPORT PANEL
      ════════════════════════════════════════════════════════════════ */}
      {showImport && (
        <div style={{
          background: '#0c0c0c', borderBottom: S.border,
          padding: '14px 20px', flexShrink: 0,
        }}>
          <p style={{ color: '#444', fontSize: '0.78rem', margin: '0 0 8px' }}>
            Paste an LRC file or plain text (one lyric per line). Existing timestamps are preserved from valid LRC.
          </p>
          <div style={{ display: 'flex', gap: '10px', alignItems: 'flex-start' }}>
            <textarea
              style={{
                flex: 1, minHeight: '120px', maxHeight: '220px',
                background: '#141414', color: '#ddd',
                border: '1px solid #2a2a2a', borderRadius: '6px',
                padding: '10px', fontSize: '0.88rem', lineHeight: 1.8,
                resize: 'vertical', fontFamily: 'monospace', outline: 'none',
              }}
              value={importText}
              onChange={e => setImportText(e.target.value)}
              placeholder={'[00:10.20]Ik Onkar\n[00:15.70]Satnam\n\n— or plain text —\nIk Onkar\nSatnam'}
            />
            <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
              <button onClick={applyImport} disabled={!importText.trim()}>Apply</button>
              <button className="secondary" onClick={() => setShowImport(false)}>Cancel</button>
            </div>
          </div>
        </div>
      )}

      {/* ════════════════════════════════════════════════════════════════
          COLUMN HEADERS
      ════════════════════════════════════════════════════════════════ */}
      <div style={{
        background: '#0a0a0a', borderBottom: S.borderDim,
        padding: '5px 20px', flexShrink: 0,
        display: 'flex', alignItems: 'center', gap: '8px',
      }}>
        <span style={{ color: '#1e1e1e', fontSize: '0.65rem', minWidth: '28px', textAlign: 'right', flexShrink: 0 }}>#</span>
        <span style={{ color: '#1e1e1e', fontSize: '0.65rem', width: '10px', flexShrink: 0 }} />
        <span style={{ color: '#1e1e1e', fontSize: '0.65rem', minWidth: '90px', flexShrink: 0 }}>TIMESTAMP</span>
        <span style={{ color: '#1e1e1e', fontSize: '0.65rem', flex: 1 }}>LYRIC</span>
        <div style={{ display: 'flex', gap: '2px', flexShrink: 0 }}>
          <button
            className="secondary"
            style={{ fontSize: '0.7rem', padding: '2px 10px', opacity: 0.6 }}
            onClick={() => addLineAfter(lines.length - 1)}
          >
            + Add Line
          </button>
        </div>
      </div>

      {/* ════════════════════════════════════════════════════════════════
          LINES LIST
      ════════════════════════════════════════════════════════════════ */}
      <div ref={listRef} style={{ flex: 1, overflowY: 'auto', paddingBottom: '20px' }}>
        {lines.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '80px 20px', color: '#2a2a2a', fontSize: '0.9rem' }}>
            No lyrics yet.{' '}
            <span
              style={{ color: '#3344aa', cursor: 'pointer', textDecoration: 'underline' }}
              onClick={() => setShowImport(true)}
            >
              Import or paste lyrics to get started.
            </span>
          </div>
        ) : (
          displayLines.map(({ line, index, matchesSearch, inRange }) => {
            if (rangeActive && !inRange) return null

            const isActive = index === activeIndex
            const isNowPlaying = index === playingIndex
            const isTimed = line.startTime !== null
            const isHighlighted = searchQuery ? matchesSearch : false

            // Row background + border-left accent
            let rowBg = 'transparent'
            let accentColor = 'transparent'

            if (isActive && isRecording) {
              rowBg = '#180808'; accentColor = '#882222'
            } else if (isActive) {
              rowBg = '#080818'; accentColor = '#2244aa'
            } else if (isNowPlaying) {
              rowBg = '#060f06'; accentColor = '#1a4a1a'
            } else if (isHighlighted) {
              rowBg = '#101008'; accentColor = '#4a4a18'
            }

            // Text color
            const textColor = isActive
              ? '#ffffff'
              : isNowPlaying
              ? '#88dd88'
              : isHighlighted
              ? '#cccc66'
              : isTimed
              ? '#b0b0b0'
              : '#404040'

            // Timestamp color
            const tsColor = isTimed
              ? isActive
                ? '#8899ff'
                : isNowPlaying
                ? '#55bb55'
                : '#3a6a4a'
              : '#1e1e1e'

            return (
              <div
                key={line.id}
                data-cursor={isActive ? '1' : undefined}
                data-playing={isNowPlaying ? '1' : undefined}
                onClick={() => handleRowClick(index)}
                onDoubleClick={e => handleRowDoubleClick(e, line, index)}
                style={{
                  display: 'flex', alignItems: 'center', gap: '8px',
                  padding: '5px 20px 5px 16px',
                  background: rowBg,
                  borderLeft: `4px solid ${accentColor}`,
                  cursor: 'default',
                  transition: 'background 0.06s',
                  minHeight: '36px',
                }}
              >
                {/* Line number */}
                <span style={{
                  ...S.monoSm, color: '#242424',
                  minWidth: '28px', textAlign: 'right', flexShrink: 0, userSelect: 'none',
                  fontSize: '0.68rem',
                }}>
                  {index + 1}
                </span>

                {/* Status icon */}
                <span style={{
                  fontSize: '0.7rem', width: '10px', flexShrink: 0, userSelect: 'none',
                  color: isActive && isRecording ? '#cc4444' : isNowPlaying ? '#44aa44' : isTimed ? '#2a4a2a' : '#1e1e1e',
                }}>
                  {isActive && isRecording ? '●' : isNowPlaying ? '♪' : isTimed ? '✓' : '·'}
                </span>

                {/* Timestamp cell */}
                {editTsId === line.id ? (
                  <input
                    autoFocus
                    value={editTsDraft}
                    onChange={e => setEditTsDraft(e.target.value)}
                    onBlur={() => commitTsEdit(line.id)}
                    onKeyDown={e => {
                      if (e.key === 'Enter') { e.preventDefault(); commitTsEdit(line.id) }
                      if (e.key === 'Escape') { e.preventDefault(); setEditTsId(null) }
                      e.stopPropagation()
                    }}
                    onClick={e => e.stopPropagation()}
                    onDoubleClick={e => e.stopPropagation()}
                    placeholder="00:00.00"
                    style={{
                      ...S.monoSm,
                      width: '90px', flexShrink: 0,
                      background: '#141428', color: '#aabbff',
                      border: '1px solid #3344aa', borderRadius: '4px',
                      padding: '2px 6px', outline: 'none',
                    }}
                  />
                ) : (
                  <span
                    title={isTimed ? 'Click to edit timestamp' : 'No timestamp — use recording mode or click to set manually'}
                    onClick={e => openTsEdit(e, line)}
                    onDoubleClick={e => e.stopPropagation()}
                    style={{
                      ...S.monoSm,
                      minWidth: '90px', flexShrink: 0,
                      color: tsColor,
                      cursor: 'text',
                      userSelect: 'none',
                      padding: '2px 0',
                      borderBottom: `1px dashed ${isTimed ? '#2a3a2a' : '#1a1a1a'}`,
                    }}
                  >
                    {isTimed ? fmtTime(line.startTime!) : '--:--.--'}
                  </span>
                )}

                {/* Lyric text input */}
                <input
                  value={line.text}
                  onChange={e => { updateLine(line.id, { text: e.target.value }); setActiveIndex(index) }}
                  onClick={e => { e.stopPropagation(); setActiveIndex(index) }}
                  onDoubleClick={e => e.stopPropagation()}
                  placeholder="lyric text…"
                  style={{
                    flex: 1, background: 'transparent', outline: 'none', border: 'none',
                    color: textColor, fontSize: '0.97rem', fontFamily: 'inherit',
                    padding: '2px 0', cursor: 'text',
                  }}
                />

                {/* Row actions */}
                <div
                  style={{
                    display: 'flex', gap: '2px', flexShrink: 0,
                    opacity: isActive ? 1 : 0,
                    transition: 'opacity 0.1s',
                  }}
                  onClick={e => e.stopPropagation()}
                  onDoubleClick={e => e.stopPropagation()}
                >
                  <button
                    className="secondary"
                    title="Move up"
                    style={{ padding: '2px 5px', fontSize: '0.7rem' }}
                    onClick={() => moveLine(index, -1)}
                    disabled={index === 0}
                  >↑</button>
                  <button
                    className="secondary"
                    title="Move down"
                    style={{ padding: '2px 5px', fontSize: '0.7rem' }}
                    onClick={() => moveLine(index, 1)}
                    disabled={index === lines.length - 1}
                  >↓</button>
                  <button
                    className="secondary"
                    title="Insert line below"
                    style={{ padding: '2px 5px', fontSize: '0.7rem' }}
                    onClick={() => addLineAfter(index)}
                  >+</button>
                  <button
                    className="secondary"
                    title="Delete line"
                    style={{ padding: '2px 5px', fontSize: '0.7rem', color: '#884444' }}
                    onClick={() => deleteLine(index)}
                  >×</button>
                </div>
              </div>
            )
          })
        )}
      </div>
    </div>
  )
}
