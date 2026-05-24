import { useState, useRef, useEffect, useCallback } from 'react'

type Line = {
  id: string
  text: string
  startTime: number | null
  flagged?: boolean
}

type Mode = 'timing' | 'edit'
type Phase = 'setup' | 'studio'

type Props = {
  audioFile: File | null
  audioUrl?: string
  initialLrc: string
  lang: 'pa' | 'hi' | 'en'
  onClose: () => void
  onSave: (lrc: string) => void
}

function uid() {
  return Math.random().toString(36).slice(2, 9)
}

function fmt(s: number): string {
  const m = Math.floor(s / 60)
  const sec = (s % 60).toFixed(2).padStart(5, '0')
  return `${String(m).padStart(2, '0')}:${sec}`
}

function parseLrcOrPlain(raw: string): Line[] {
  const rows = raw.split(/\r?\n/).filter(l => l.trim())
  return rows.map(line => {
    const m = line.match(/^\[(\d{2}):(\d{2}\.\d{1,3})\](.*)$/)
    if (m) {
      return { id: uid(), text: m[3].trim(), startTime: Number(m[1]) * 60 + Number(m[2]) }
    }
    return { id: uid(), text: line.trim(), startTime: null }
  })
}

function toLrc(lines: Line[]): string {
  return lines
    .filter(l => l.text.trim() && l.startTime !== null)
    .map(l => `[${fmt(l.startTime!)}]${l.text}`)
    .join('\n')
}

const LANG_NAMES: Record<string, string> = { pa: 'Punjabi', hi: 'Hindi', en: 'English' }

export function LrcStudio({ audioFile, audioUrl, initialLrc, lang, onClose, onSave }: Props) {
  const audioRef = useRef<HTMLAudioElement>(null)
  const activeLineRef = useRef<HTMLDivElement>(null)

  const [phase, setPhase] = useState<Phase>(initialLrc.trim() ? 'studio' : 'setup')
  const [rawText, setRawText] = useState(initialLrc)
  const [lines, setLines] = useState<Line[]>(() => parseLrcOrPlain(initialLrc))
  const [activeIndex, setActiveIndex] = useState(0)
  const [mode, setMode] = useState<Mode>('timing')
  const [currentTime, setCurrentTime] = useState(0)
  const [duration, setDuration] = useState(0)
  const [isPlaying, setIsPlaying] = useState(false)
  const [playbackRate, setPlaybackRate] = useState(1)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [blobUrl, setBlobUrl] = useState<string | null>(null)

  // Create blob URL for File uploads
  useEffect(() => {
    if (!audioFile) return
    const url = URL.createObjectURL(audioFile)
    setBlobUrl(url)
    return () => URL.revokeObjectURL(url)
  }, [audioFile])

  const audioSrc = blobUrl ?? audioUrl ?? ''

  // Wire up audio events
  useEffect(() => {
    const audio = audioRef.current
    if (!audio) return
    const onTime = () => setCurrentTime(audio.currentTime)
    const onMeta = () => setDuration(audio.duration)
    const onPlay = () => setIsPlaying(true)
    const onPause = () => setIsPlaying(false)
    audio.addEventListener('timeupdate', onTime)
    audio.addEventListener('loadedmetadata', onMeta)
    audio.addEventListener('play', onPlay)
    audio.addEventListener('pause', onPause)
    return () => {
      audio.removeEventListener('timeupdate', onTime)
      audio.removeEventListener('loadedmetadata', onMeta)
      audio.removeEventListener('play', onPlay)
      audio.removeEventListener('pause', onPause)
    }
  }, [phase])

  useEffect(() => {
    if (audioRef.current) audioRef.current.playbackRate = playbackRate
  }, [playbackRate])

  // Scroll active line into view
  useEffect(() => {
    activeLineRef.current?.scrollIntoView({ block: 'center', behavior: 'smooth' })
  }, [activeIndex])

  // Which line is currently playing (for edit mode indicator)
  const lineAtTime = useCallback((t: number) => {
    let result = -1
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].startTime !== null && lines[i].startTime! <= t) result = i
    }
    return result
  }, [lines])

  const stamp = useCallback(() => {
    const audio = audioRef.current
    if (!audio || activeIndex < 0 || activeIndex >= lines.length) return
    const t = audio.currentTime
    setLines(prev => {
      const next = [...prev]
      next[activeIndex] = { ...next[activeIndex], startTime: t }
      return next
    })
    setActiveIndex(prev => Math.min(prev + 1, lines.length - 1))
  }, [activeIndex, lines.length])

  // Keyboard shortcuts — only active in studio phase and not when editing a line
  useEffect(() => {
    if (phase !== 'studio') return
    const handler = (e: KeyboardEvent) => {
      if (editingId) return
      const tag = (e.target as HTMLElement)?.tagName
      if (tag === 'INPUT' || tag === 'TEXTAREA') return
      const audio = audioRef.current
      if (!audio) return

      if (e.code === 'Space') { e.preventDefault(); audio.paused ? audio.play() : audio.pause() }
      if (e.code === 'Enter') { e.preventDefault(); stamp() }
      if (e.code === 'Backspace') { e.preventDefault(); setActiveIndex(prev => Math.max(prev - 1, 0)) }
      if (e.code === 'ArrowLeft') { e.preventDefault(); audio.currentTime = Math.max(0, audio.currentTime - (e.shiftKey ? 5 : e.ctrlKey ? 0.5 : 2)) }
      if (e.code === 'ArrowRight') { e.preventDefault(); audio.currentTime = audio.currentTime + (e.shiftKey ? 5 : e.ctrlKey ? 0.5 : 2) }
      if (e.key.toLowerCase() === 'f') {
        setLines(prev => {
          const next = [...prev]
          if (activeIndex >= 0 && activeIndex < next.length) {
            next[activeIndex] = { ...next[activeIndex], flagged: !next[activeIndex].flagged }
          }
          return next
        })
      }
      if (e.ctrlKey && e.key.toLowerCase() === 'e') { e.preventDefault(); setMode(m => m === 'timing' ? 'edit' : 'timing') }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [phase, stamp, activeIndex, editingId])

  // ── Handlers ──────────────────────────────────────────────

  function handleBeginTiming() {
    const parsed = parseLrcOrPlain(rawText)
    setLines(parsed)
    setActiveIndex(0)
    setPhase('studio')
  }

  function handleLineClick(i: number) {
    setActiveIndex(i)
    if (lines[i].startTime !== null && audioRef.current) {
      audioRef.current.currentTime = lines[i].startTime!
    }
  }

  function handleInsert(afterIndex: number) {
    setLines(prev => {
      const next = [...prev]
      next.splice(afterIndex + 1, 0, { id: uid(), text: '', startTime: null })
      return next
    })
    setActiveIndex(afterIndex + 1)
  }

  function handleDuplicate(i: number) {
    setLines(prev => {
      const next = [...prev]
      next.splice(i + 1, 0, { ...prev[i], id: uid(), startTime: null })
      return next
    })
  }

  function handleDelete(i: number) {
    setLines(prev => prev.filter((_, idx) => idx !== i))
    setActiveIndex(prev => Math.max(0, Math.min(prev, lines.length - 2)))
  }

  function handleTextChange(id: string, text: string) {
    setLines(prev => prev.map(l => l.id === id ? { ...l, text } : l))
  }

  function handleClearTimestamp(i: number) {
    setLines(prev => {
      const next = [...prev]
      next[i] = { ...next[i], startTime: null }
      return next
    })
    setActiveIndex(i)
  }

  function handleSave() {
    onSave(toLrc(lines))
    onClose()
  }

  // ── Render ────────────────────────────────────────────────

  const timedCount = lines.filter(l => l.startTime !== null).length
  const nowAt = lineAtTime(currentTime)

  // SETUP PHASE
  if (phase === 'setup') {
    return (
      <div style={{ position: 'fixed', inset: 0, background: '#0d0d0d', zIndex: 1000, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '40px' }}>
        <div style={{ width: '100%', maxWidth: '640px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <h2 style={{ color: '#fff', margin: 0 }}>LRC Studio — {LANG_NAMES[lang]}</h2>
              <p style={{ color: '#666', margin: '4px 0 0' }}>Paste your lyrics below, one line per row</p>
            </div>
            <button className="secondary" onClick={onClose}>Cancel</button>
          </div>

          <textarea
            style={{ width: '100%', minHeight: '320px', background: '#1a1a1a', color: '#eee', border: '1px solid #333', borderRadius: '8px', padding: '16px', fontSize: '1rem', lineHeight: 1.7, resize: 'vertical', fontFamily: 'inherit', boxSizing: 'border-box' }}
            value={rawText}
            onChange={e => setRawText(e.target.value)}
            placeholder={`Paste ${LANG_NAMES[lang]} lyrics here, one line per row…\n\nAlready have an LRC file? Paste it here — timestamps will be preserved.`}
          />

          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ color: '#555', fontSize: '0.85rem' }}>
              {rawText.trim() ? `${rawText.trim().split('\n').filter(l => l.trim()).length} lines detected` : 'No content yet'}
            </span>
            <button onClick={handleBeginTiming} disabled={!rawText.trim()}>
              Begin Timing →
            </button>
          </div>
        </div>
      </div>
    )
  }

  // STUDIO PHASE
  return (
    <div style={{ position: 'fixed', inset: 0, background: '#0a0a0a', zIndex: 1000, display: 'flex', flexDirection: 'column' }}>
      {audioSrc && <audio ref={audioRef} src={audioSrc} preload="metadata" style={{ display: 'none' }} />}

      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 24px', borderBottom: '1px solid #1f1f1f', background: '#111', flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
          <h2 style={{ margin: 0, color: '#fff', fontSize: '1.1rem' }}>LRC Studio</h2>
          <span style={{ padding: '3px 10px', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 700, letterSpacing: 1, background: mode === 'timing' ? 'var(--accent)' : '#444', color: '#fff' }}>
            {mode === 'timing' ? 'TIMING' : 'EDIT'}
          </span>
          <span style={{ color: '#555', fontSize: '0.85rem' }}>{LANG_NAMES[lang]}</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span style={{ color: '#555', fontSize: '0.85rem' }}>{timedCount} / {lines.length} lines timed</span>
          <button onClick={handleSave} disabled={timedCount === 0}>Save & Close</button>
          <button className="secondary" onClick={onClose}>Discard</button>
        </div>
      </div>

      {/* Body */}
      <div style={{ display: 'flex', flex: 1, overflow: 'hidden' }}>

        {/* ── LEFT: Audio Player ── */}
        <div style={{ width: '300px', flexShrink: 0, display: 'flex', flexDirection: 'column', gap: '18px', padding: '24px 20px', borderRight: '1px solid #1a1a1a', background: '#111', overflowY: 'auto' }}>

          {!audioSrc && (
            <div style={{ color: '#555', fontSize: '0.85rem', background: '#1a1a1a', padding: '12px', borderRadius: '8px' }}>
              No audio loaded. Upload audio in the track editor first, then re-open the studio.
            </div>
          )}

          {/* Big time display */}
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontFamily: 'monospace', fontSize: '2.2rem', color: '#fff', letterSpacing: 2 }}>{fmt(currentTime)}</div>
            <div style={{ fontFamily: 'monospace', fontSize: '0.9rem', color: '#444', marginTop: '2px' }}>/ {fmt(duration)}</div>
          </div>

          {/* Seek bar */}
          <input type="range" min={0} max={duration || 100} step={0.01} value={currentTime}
            onChange={e => { if (audioRef.current) audioRef.current.currentTime = Number(e.target.value) }}
            style={{ width: '100%', accentColor: 'var(--accent)' }}
          />

          {/* Play controls */}
          <div style={{ display: 'flex', justifyContent: 'center', gap: '8px' }}>
            <button className="secondary" onClick={() => { if (audioRef.current) audioRef.current.currentTime = Math.max(0, currentTime - 5) }} style={{ fontSize: '0.8rem', padding: '6px 10px' }}>−5s</button>
            <button onClick={() => audioRef.current?.paused ? audioRef.current?.play() : audioRef.current?.pause()} style={{ minWidth: '80px' }}>
              {isPlaying ? '⏸' : '▶'}
            </button>
            <button className="secondary" onClick={() => { if (audioRef.current) audioRef.current.currentTime = currentTime + 5 }} style={{ fontSize: '0.8rem', padding: '6px 10px' }}>+5s</button>
          </div>

          {/* Speed */}
          <div>
            <div style={{ color: '#555', fontSize: '0.75rem', marginBottom: '6px' }}>SPEED</div>
            <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
              {[0.5, 0.75, 1, 1.25].map(r => (
                <button key={r} className={playbackRate === r ? '' : 'secondary'}
                  style={{ padding: '4px 8px', fontSize: '0.78rem', flex: 1 }}
                  onClick={() => setPlaybackRate(r)}>
                  {r}×
                </button>
              ))}
            </div>
          </div>

          {/* Mode */}
          <div>
            <div style={{ color: '#555', fontSize: '0.75rem', marginBottom: '6px' }}>MODE</div>
            <div style={{ display: 'flex', gap: '6px' }}>
              <button className={mode === 'timing' ? '' : 'secondary'} style={{ flex: 1 }} onClick={() => setMode('timing')}>Timing</button>
              <button className={mode === 'edit' ? '' : 'secondary'} style={{ flex: 1 }} onClick={() => setMode('edit')}>Edit</button>
            </div>
          </div>

          {/* Edit mode: show what's playing now */}
          {mode === 'edit' && nowAt >= 0 && (
            <div style={{ background: '#0f2010', border: '1px solid #1a3a1a', borderRadius: '8px', padding: '10px 12px' }}>
              <div style={{ color: '#4a9', fontSize: '0.75rem', marginBottom: '4px' }}>Now at {fmt(currentTime)}</div>
              <div style={{ color: '#cec', fontSize: '0.9rem' }}>{lines[nowAt]?.text || '—'}</div>
            </div>
          )}

          {/* Shortcuts */}
          <div style={{ color: '#3a3a3a', fontSize: '0.75rem', lineHeight: 2, marginTop: 'auto', paddingTop: '12px', borderTop: '1px solid #1a1a1a' }}>
            <div style={{ color: '#555', fontWeight: 600, marginBottom: '4px' }}>SHORTCUTS</div>
            <div><span style={{ color: '#555' }}>Space</span> — Play / Pause</div>
            <div><span style={{ color: '#555' }}>Enter</span> — Stamp &amp; Next</div>
            <div><span style={{ color: '#555' }}>Backspace</span> — Go Back</div>
            <div><span style={{ color: '#555' }}>← →</span> — Seek ±2s</div>
            <div><span style={{ color: '#555' }}>Shift+← →</span> — ±5s</div>
            <div><span style={{ color: '#555' }}>Ctrl+← →</span> — ±0.5s</div>
            <div><span style={{ color: '#555' }}>F</span> — Flag line</div>
            <div><span style={{ color: '#555' }}>Ctrl+E</span> — Toggle mode</div>
            <div><span style={{ color: '#555' }}>Dbl-click text</span> — Edit inline</div>
          </div>
        </div>

        {/* ── RIGHT: Lyrics ── */}
        <div style={{ flex: 1, overflowY: 'auto', padding: '16px 20px', background: '#0d0d0d' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '3px' }}>
            {lines.map((line, i) => {
              const isActive = i === activeIndex
              const isNow = mode === 'edit' && i === nowAt
              const isTimed = line.startTime !== null

              return (
                <div
                  key={line.id}
                  ref={isActive ? activeLineRef : undefined}
                  onClick={() => handleLineClick(i)}
                  style={{
                    display: 'flex', alignItems: 'center', gap: '8px', padding: '7px 10px',
                    borderRadius: '6px', cursor: 'pointer', transition: 'background 0.1s',
                    background: isActive ? '#10102a' : isNow ? '#0a1a0a' : 'transparent',
                    border: isActive ? '1px solid var(--accent)' : isNow ? '1px solid #1a3a1a' : '1px solid transparent',
                  }}
                >
                  {/* Line number */}
                  <span style={{ fontFamily: 'monospace', fontSize: '0.7rem', color: '#333', minWidth: '26px', textAlign: 'right', flexShrink: 0 }}>
                    {i + 1}
                  </span>

                  {/* Status */}
                  <span style={{ fontSize: '0.75rem', minWidth: '14px', flexShrink: 0 }}>
                    {line.flagged ? '🚩' : isActive ? '▶' : isTimed ? '✓' : '·'}
                  </span>

                  {/* Timestamp — click to clear */}
                  <span
                    title={isTimed ? 'Click to clear this timestamp and re-time from here' : ''}
                    onClick={e => { if (isTimed) { e.stopPropagation(); handleClearTimestamp(i) } }}
                    style={{
                      fontFamily: 'monospace', fontSize: '0.78rem', minWidth: '72px', flexShrink: 0,
                      color: isTimed ? '#4a8a6a' : '#2a2a2a',
                      cursor: isTimed ? 'pointer' : 'default',
                    }}
                  >
                    {isTimed ? `[${fmt(line.startTime!)}]` : '[--:--.--]'}
                  </span>

                  {/* Text — double-click to edit */}
                  {editingId === line.id ? (
                    <input
                      autoFocus
                      value={line.text}
                      onChange={e => handleTextChange(line.id, e.target.value)}
                      onBlur={() => setEditingId(null)}
                      onKeyDown={e => {
                        if (e.key === 'Enter' || e.key === 'Escape') { e.preventDefault(); setEditingId(null) }
                        e.stopPropagation()
                      }}
                      onClick={e => e.stopPropagation()}
                      style={{ flex: 1, background: '#1e1e1e', color: '#fff', border: '1px solid #444', borderRadius: '4px', padding: '2px 8px', fontSize: '0.95rem', fontFamily: 'inherit' }}
                    />
                  ) : (
                    <span
                      onDoubleClick={e => { e.stopPropagation(); setEditingId(line.id) }}
                      style={{ flex: 1, fontSize: '0.95rem', color: isActive ? '#fff' : isTimed ? '#bbb' : '#444', userSelect: 'none' }}
                    >
                      {line.text || <em style={{ color: '#2a2a2a', fontStyle: 'normal' }}>empty</em>}
                    </span>
                  )}

                  {/* Action buttons */}
                  <div style={{ display: 'flex', gap: '3px', flexShrink: 0, opacity: isActive ? 1 : 0.2 }}>
                    <button className="secondary" title="Duplicate line"
                      style={{ padding: '2px 6px', fontSize: '0.7rem' }}
                      onClick={e => { e.stopPropagation(); handleDuplicate(i) }}>⊕</button>
                    <button className="secondary" title="Insert line after"
                      style={{ padding: '2px 6px', fontSize: '0.7rem' }}
                      onClick={e => { e.stopPropagation(); handleInsert(i) }}>+</button>
                    <button className="secondary" title="Delete line"
                      style={{ padding: '2px 6px', fontSize: '0.7rem', color: '#c55' }}
                      onClick={e => { e.stopPropagation(); handleDelete(i) }}>×</button>
                  </div>
                </div>
              )
            })}

            <button className="secondary"
              style={{ marginTop: '8px', width: '100%', opacity: 0.4, fontSize: '0.85rem' }}
              onClick={() => setLines(prev => [...prev, { id: uid(), text: '', startTime: null }])}>
              + Add Line
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
