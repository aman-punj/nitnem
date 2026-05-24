import { useState, useRef, useEffect, useCallback, useMemo } from 'react'

type Line = { id: string; text: string; startTime: number | null }
type Props = { audioFile: File | null; audioUrl?: string; initialLrc: string; lang: 'pa' | 'hi' | 'en'; onClose: () => void; onSave: (lrc: string) => void }

function uid() { return Math.random().toString(36).slice(2, 9) }
function fmt(s: number): string {
  if (!isFinite(s) || isNaN(s)) return '--:--.--'
  const m = Math.floor(s / 60); const sec = (s % 60).toFixed(2).padStart(5, '0')
  return `${String(m).padStart(2, '0')}:${sec}`
}
function parseTime(str: string): number | null {
  const s = str.trim(); if (!s) return null
  const m1 = s.match(/^(\d+):(\d{1,2}(?:\.\d{1,3})?)$/); if (m1) return Number(m1[1]) * 60 + Number(m1[2])
  const m2 = s.match(/^(\d+(?:\.\d{1,3})?)$/); if (m2) return Number(m2[1])
  return null
}
function parseLrc(raw: string): Line[] {
  return raw.split(/\r?\n/).filter(l => l.trim()).map(line => {
    const m = line.match(/^\[(\d{1,3}):(\d{2}\.\d{1,3})\](.*)$/)
    if (m) { const t = Number(m[1]) * 60 + Number(m[2]); if (isFinite(t) && !isNaN(t)) return { id: uid(), text: m[3].trim(), startTime: t } }
    const text = line.replace(/^\[[^\]]*\]/, '').trim() || line.trim()
    return { id: uid(), text, startTime: null }
  })
}
function toLrc(lines: Line[]): string {
  return lines.filter(l => l.text.trim()).map(l => l.startTime !== null ? `[${fmt(l.startTime)}]${l.text}` : l.text).join('\n')
}

export function LrcStudio({ audioFile, audioUrl, initialLrc, lang, onClose, onSave }: Props) {
  const audioRef = useRef<HTMLAudioElement>(null)
  const activeLineRef = useRef<HTMLDivElement>(null)
  const listRef = useRef<HTMLDivElement>(null)

  const [lines, setLines] = useState<Line[]>(() => parseLrc(initialLrc || ''))
  const [activeIndex, setActiveIndex] = useState(0)
  const [dirty, setDirty] = useState(false)
  const [blobUrl, setBlobUrl] = useState<string | null>(null)
  const [currentTime, setCurrentTime] = useState(0)
  const [duration, setDuration] = useState(0)
  const [isPlaying, setIsPlaying] = useState(false)
  const [playbackRate, setPlaybackRate] = useState(1)
  const [audioError, setAudioError] = useState<string | null>(null)
  const [isRecording, setIsRecording] = useState(false)
  const [showImport, setShowImport] = useState(!initialLrc.trim())
  const [importText, setImportText] = useState(initialLrc)
  const [editTsId, setEditTsId] = useState<string | null>(null)
  const [editTsDraft, setEditTsDraft] = useState('')

  const isRecordingRef = useRef(false); useEffect(() => { isRecordingRef.current = isRecording }, [isRecording])

  useEffect(() => {
    if (!audioFile) return
    const url = URL.createObjectURL(audioFile); setBlobUrl(url)
    return () => URL.revokeObjectURL(url)
  }, [audioFile])
  const audioSrc = blobUrl ?? audioUrl ?? ''

  useEffect(() => {
    const audio = audioRef.current; if (!audio) return
    setAudioError(null)
    const onTime = () => setCurrentTime(audio.currentTime)
    const onDuration = () => { const d = audio.duration; if (isFinite(d) && !isNaN(d)) setDuration(d) }
    const onPlay = () => setIsPlaying(true)
    const onPause = () => setIsPlaying(false)
    const onEnded = () => { setIsPlaying(false); if (isRecordingRef.current) setIsRecording(false) }
    const onError = () => {
      const msgs: Record<number, string> = { 1: 'Aborted', 2: 'Network error', 3: 'Decode error', 4: 'Format not supported' }
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

  useEffect(() => { if (audioRef.current) audioRef.current.playbackRate = playbackRate }, [playbackRate])

  const playingIndex = useMemo(() => {
    let result = -1
    for (let i = 0; i < lines.length; i++) { if (lines[i].startTime !== null && lines[i].startTime! <= currentTime) result = i }
    return result
  }, [lines, currentTime])

  useEffect(() => { activeLineRef.current?.scrollIntoView({ block: 'nearest', behavior: 'smooth' }) }, [activeIndex])
  useEffect(() => { if (!isPlaying || isRecording) return; const el = listRef.current?.querySelector('[data-playing="1"]') as HTMLElement | null; el?.scrollIntoView({ block: 'nearest', behavior: 'smooth' }) }, [playingIndex, isPlaying, isRecording])

  const stamp = useCallback(() => {
    const audio = audioRef.current; if (!audio) return
    setLines(prev => { const next = [...prev]; if (activeIndex >= 0 && activeIndex < next.length) next[activeIndex] = { ...next[activeIndex], startTime: audio.currentTime }; return next })
    setDirty(true)
    setActiveIndex(prev => Math.min(prev + 1, lines.length - 1))
  }, [activeIndex, lines.length])

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (showImport || editTsId) return
      const isInput = (e.target as HTMLElement)?.tagName === 'INPUT' || (e.target as HTMLElement)?.tagName === 'TEXTAREA'
      const audio = audioRef.current; if (!audio) return
      if (e.code === 'Space' && !isInput) {
        e.preventDefault()
        if (isRecording) stamp()
        else audio.paused ? audio.play().catch(() => {}) : audio.pause()
      }
      if (isInput) return
      if (e.code === 'Backspace' && isRecording) { e.preventDefault(); setActiveIndex(prev => Math.max(prev - 1, 0)) }
      if (e.key === 'Escape') { e.preventDefault(); if (isRecording) setIsRecording(false); else if (editTsId) setEditTsId(null) }
      if (e.code === 'ArrowLeft') { e.preventDefault(); audio.currentTime = Math.max(0, audio.currentTime - (e.shiftKey ? 5 : e.ctrlKey ? 0.5 : 2)) }
      if (e.code === 'ArrowRight') { e.preventDefault(); audio.currentTime = Math.min(duration, audio.currentTime + (e.shiftKey ? 5 : e.ctrlKey ? 0.5 : 2)) }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [stamp, isRecording, showImport, editTsId, duration])

  const seek = useCallback((t: number) => { if (audioRef.current) audioRef.current.currentTime = Math.max(0, Math.min(t, duration || Infinity)) }, [duration])
  const seekAndPlay = useCallback((t: number) => { seek(t); audioRef.current?.play().catch(() => {}) }, [seek])
  const handleSeekBar = (e: React.MouseEvent<HTMLDivElement>) => { if (!audioRef.current || duration === 0) return; const rect = e.currentTarget.getBoundingClientRect(); seek(((e.clientX - rect.left) / rect.width) * duration) }

  const mutLines = (fn: (prev: Line[]) => Line[]) => { setLines(fn); setDirty(true) }
  const updateLine = (id: string, patch: Partial<Line>) => mutLines(prev => prev.map(l => l.id === id ? { ...l, ...patch } : l))
  const addLineAfter = (afterIndex: number) => { mutLines(prev => { const next = [...prev]; next.splice(afterIndex + 1, 0, { id: uid(), text: '', startTime: null }); return next }); setActiveIndex(afterIndex + 1) }
  const deleteLine = (i: number) => { mutLines(prev => prev.filter((_, idx) => idx !== i)); setActiveIndex(prev => Math.max(0, Math.min(prev, lines.length - 2))) }
  const moveLine = (i: number, dir: -1 | 1) => { const j = i + dir; if (j < 0 || j >= lines.length) return; mutLines(prev => { const next = [...prev]; [next[i], next[j]] = [next[j], next[i]]; return next }); setActiveIndex(j) }

  const openTsEdit = (e: React.MouseEvent, line: Line) => { e.stopPropagation(); setEditTsId(line.id); setEditTsDraft(line.startTime !== null ? fmt(line.startTime) : '') }
  const commitTsEdit = (lineId: string) => { const t = parseTime(editTsDraft); updateLine(lineId, { startTime: t }); setEditTsId(null) }

  const handleRowClick = (index: number) => setActiveIndex(index)
  const handleRowDoubleClick = (e: React.MouseEvent, line: Line, index: number) => {
    if ((e.target as HTMLElement).tagName === 'INPUT') return
    setActiveIndex(index)
    if (line.startTime !== null) seekAndPlay(line.startTime)
  }

  const timedCount = useMemo(() => lines.filter(l => l.startTime !== null).length, [lines])
  const progressPercent = duration > 0 ? (currentTime / duration) * 100 : 0

  return (
    <div style={{ position: 'fixed', inset: 0, zIndex: 1000, background: '#080808', display: 'flex', flexDirection: 'column', color: '#ccc' }}>
      {audioSrc && <audio ref={audioRef} src={audioSrc} preload="metadata" crossOrigin="anonymous" style={{ display: 'none' }} />}

      {/* HEADER */}
      <div style={{ background: '#0c0c0c', borderBottom: '1px solid #1e1e1e', padding: '10px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span style={{ color: '#fff', fontWeight: 700, fontSize: '1rem' }}>Timing Studio</span>
          <span style={{ color: '#4488bb', fontSize: '0.85rem' }}>({lang})</span>
          {isRecording && <span style={{ background: '#2a0808', color: '#ff6666', padding: '2px 8px', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 700 }}>⏺ Recording</span>}
          <span style={{ color: '#333', fontSize: '0.75rem' }}>{timedCount} / {lines.length} timed</span>
        </div>
        <div style={{ display: 'flex', gap: '6px' }}>
          <button className="secondary" style={{ fontSize: '0.8rem', padding: '5px 12px' }} onClick={() => setShowImport(v => !v)}>{showImport ? 'Done' : '↑ Import'}</button>
          <button style={{ padding: '5px 18px' }} onClick={() => { onSave(toLrc(lines)); setDirty(false); onClose() }} disabled={lines.length === 0}>Save</button>
          <button className="secondary" style={{ padding: '5px 10px' }} onClick={onClose}>✕</button>
        </div>
      </div>

      {/* TRANSPORT */}
      <div style={{ background: '#0f0f0f', borderBottom: '1px solid #1e1e1e', padding: '10px 20px', flexShrink: 0 }}>
        {!audioSrc ? (
          <p style={{ color: '#333', fontSize: '0.85rem', margin: 0 }}>No audio — upload in the track editor first.</p>
        ) : audioError ? (
          <p style={{ color: '#cc4444', fontSize: '0.85rem', margin: 0 }}>⚠ {audioError}</p>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
            <button className="secondary" onClick={() => { if (audioRef.current) { audioRef.current.pause(); audioRef.current.currentTime = 0 } }} style={{ padding: '6px 10px', fontSize: '0.85rem' }}>■</button>
            <button className="secondary" onClick={() => seek(currentTime - 5)} style={{ padding: '6px 10px', fontSize: '0.8rem' }}>−5s</button>
            <button onClick={() => audioRef.current?.paused ? audioRef.current?.play().catch(() => {}) : audioRef.current?.pause()} style={{ minWidth: '80px', padding: '6px 12px' }}>{isPlaying ? '⏸ Pause' : '▶ Play'}</button>
            <button className="secondary" onClick={() => seek(currentTime + 5)} style={{ padding: '6px 10px', fontSize: '0.8rem' }}>+5s</button>
            <span style={{ fontFamily: 'monospace', color: '#bbb', fontSize: '0.9rem', minWidth: '70px' }}>{fmt(currentTime)}</span>
            <div onClick={handleSeekBar} style={{ flex: 1, minWidth: '80px', height: '6px', background: '#1e1e1e', borderRadius: '3px', cursor: 'pointer', position: 'relative' }}>
              <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: `${progressPercent}%`, background: 'var(--accent, #4455cc)', borderRadius: '3px' }} />
            </div>
            <span style={{ fontFamily: 'monospace', color: '#444', fontSize: '0.9rem', minWidth: '70px' }}>{fmt(duration)}</span>
            <div style={{ display: 'flex', gap: '2px' }}>
              {[0.5, 0.75, 1, 1.25].map(r => (<button key={r} className={playbackRate === r ? '' : 'secondary'} style={{ padding: '4px 7px', fontSize: '0.72rem' }} onClick={() => setPlaybackRate(r)}>{r}×</button>))}
            </div>
            <button style={{ padding: '6px 14px' }} onClick={() => { isRecording ? setIsRecording(false) : (setIsRecording(true), audioRef.current?.play().catch(() => {})) }} title="Space to stamp, Ctrl+Space to go back, Esc to stop">{isRecording ? '⏹ Stop Rec' : '⏺ Record'}</button>
          </div>
        )}
      </div>

      {/* IMPORT PANEL */}
      {showImport && (
        <div style={{ background: '#0c0c0c', borderBottom: '1px solid #1e1e1e', padding: '12px 20px', flexShrink: 0 }}>
          <textarea style={{ width: '100%', minHeight: '120px', maxHeight: '200px', background: '#141414', color: '#ddd', border: '1px solid #2a2a2a', borderRadius: '6px', padding: '10px', fontSize: '0.9rem', lineHeight: 1.8, resize: 'vertical', fontFamily: 'monospace', outline: 'none' }} value={importText} onChange={e => setImportText(e.target.value)} placeholder="Paste lyrics (plain text or LRC format)..." />
          <div style={{ display: 'flex', gap: '6px', marginTop: '8px' }}>
            <button onClick={() => { setLines(parseLrc(importText)); setActiveIndex(0); setShowImport(false) }} disabled={!importText.trim()}>Apply</button>
            <button className="secondary" onClick={() => setShowImport(false)}>Cancel</button>
          </div>
        </div>
      )}

      {/* LINES */}
      <div ref={listRef} style={{ flex: 1, overflowY: 'auto', paddingBottom: '20px' }}>
        {lines.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '80px 20px', color: '#2a2a2a', fontSize: '0.9rem' }}>No lyrics. <span style={{ color: '#3344aa', cursor: 'pointer' }} onClick={() => setShowImport(true)}>Import or paste lyrics.</span></div>
        ) : (
          lines.map((line, i) => {
            const isActive = i === activeIndex
            const isPlaying_ = i === playingIndex
            const isTimed = line.startTime !== null
            let bg = 'transparent', accentColor = 'transparent'
            if (isActive && isRecording) { bg = '#180808'; accentColor = '#882222' }
            else if (isActive) { bg = '#080818'; accentColor = '#2244aa' }
            else if (isPlaying_) { bg = '#060f06'; accentColor = '#1a4a1a' }
            const textColor = isActive ? '#ffffff' : isPlaying_ ? '#88dd88' : isTimed ? '#b0b0b0' : '#404040'
            const tsColor = isTimed ? (isActive ? '#8899ff' : isPlaying_ ? '#55bb55' : '#3a6a4a') : '#1e1e1e'
            return (
              <div key={line.id} data-playing={isPlaying_ ? '1' : undefined} ref={isActive ? activeLineRef : undefined} onClick={() => handleRowClick(i)} onDoubleClick={e => handleRowDoubleClick(e, line, i)} style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '5px 20px 5px 16px', background: bg, borderLeft: `4px solid ${accentColor}`, cursor: 'default', minHeight: '36px' }}>
                <span style={{ fontFamily: 'monospace', fontSize: '0.68rem', color: '#242424', minWidth: '24px', textAlign: 'right', flexShrink: 0 }}>{i + 1}</span>
                <span style={{ fontSize: '0.7rem', width: '10px', flexShrink: 0, color: isActive && isRecording ? '#cc4444' : isPlaying_ ? '#44aa44' : isTimed ? '#2a4a2a' : '#1e1e1e' }}>{isActive && isRecording ? '●' : isPlaying_ ? '♪' : isTimed ? '✓' : '·'}</span>
                {editTsId === line.id ? (
                  <input autoFocus value={editTsDraft} onChange={e => setEditTsDraft(e.target.value)} onBlur={() => commitTsEdit(line.id)} onKeyDown={e => { if (e.key === 'Enter') commitTsEdit(line.id); if (e.key === 'Escape') setEditTsId(null); e.stopPropagation() }} onClick={e => e.stopPropagation()} onDoubleClick={e => e.stopPropagation()} placeholder="00:00.00" style={{ fontFamily: 'monospace', fontSize: '0.8rem', width: '90px', flexShrink: 0, background: '#141428', color: '#aabbff', border: '1px solid #3344aa', borderRadius: '4px', padding: '2px 6px', outline: 'none' }} />
                ) : (
                  <span onClick={e => openTsEdit(e, line)} onDoubleClick={e => e.stopPropagation()} title={isTimed ? 'Click to edit' : 'No timestamp yet'} style={{ fontFamily: 'monospace', fontSize: '0.8rem', minWidth: '90px', flexShrink: 0, color: tsColor, cursor: 'text', userSelect: 'none', padding: '2px 0' }}>{isTimed ? fmt(line.startTime!) : '--:--.--'}</span>
                )}
                <input value={line.text} onChange={e => { updateLine(line.id, { text: e.target.value }); setActiveIndex(i) }} onClick={e => { e.stopPropagation(); setActiveIndex(i) }} onDoubleClick={e => e.stopPropagation()} placeholder="lyric…" style={{ flex: 1, background: 'transparent', outline: 'none', border: 'none', color: textColor, fontSize: '0.97rem', fontFamily: 'inherit', padding: '2px 0', cursor: 'text' }} />
                <div style={{ display: 'flex', gap: '2px', flexShrink: 0, opacity: isActive ? 1 : 0 }} onClick={e => e.stopPropagation()} onDoubleClick={e => e.stopPropagation()}>
                  <button className="secondary" style={{ padding: '2px 5px', fontSize: '0.7rem' }} onClick={() => moveLine(i, -1)} disabled={i === 0}>↑</button>
                  <button className="secondary" style={{ padding: '2px 5px', fontSize: '0.7rem' }} onClick={() => moveLine(i, 1)} disabled={i === lines.length - 1}>↓</button>
                  <button className="secondary" style={{ padding: '2px 5px', fontSize: '0.7rem' }} onClick={() => addLineAfter(i)}>+</button>
                  <button className="secondary" style={{ padding: '2px 5px', fontSize: '0.7rem', color: '#884444' }} onClick={() => deleteLine(i)}>×</button>
                </div>
              </div>
            )
          })
        )}
      </div>
    </div>
  )
}
