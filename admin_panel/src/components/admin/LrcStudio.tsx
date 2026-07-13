import { useState, useRef, useEffect, useCallback, useMemo } from 'react'
import { saveDraft, loadDraft, deleteDraft, exportDraftAsFile, timeAgo, type DraftData } from '../../lib/draftService'

type Line = { id: string; text: string; startTime: number | null }
type Props = {
  audioFile: File | null
  audioUrl?: string
  initialLrc: string
  lang: 'pa' | 'hi' | 'en'
  draftKey?: string
  onClose: () => void
  onSave: (lrc: string) => void
}

function uid() {
  return Math.random().toString(36).slice(2, 9)
}

function fmt(s: number): string {
  if (!Number.isFinite(s)) return '--:--.--'
  const m = Math.floor(s / 60)
  const sec = (s % 60).toFixed(2).padStart(5, '0')
  return `${String(m).padStart(2, '0')}:${sec}`
}

function parseTime(str: string): number | null {
  const s = str.trim()
  if (!s) return null
  const mmss = s.match(/^(\d+):(\d{1,2}(?:\.\d{1,3})?)$/)
  if (mmss) return Number(mmss[1]) * 60 + Number(mmss[2])
  const seconds = s.match(/^(\d+(?:\.\d{1,3})?)$/)
  if (seconds) return Number(seconds[1])
  return null
}

function parseLrcLines(raw: string): Line[] {
  return raw
    .split(/\r?\n/)
    .filter(line => line.trim())
    .map(line => {
      const m = line.match(/^\[(\d{1,3}):(\d{2}(?:\.\d{1,3})?)\](.*)$/)
      if (m) {
        const t = Number(m[1]) * 60 + Number(m[2])
        if (Number.isFinite(t)) return { id: uid(), text: m[3].trim(), startTime: t }
      }
      const text = line.replace(/^\[[^\]]*\]/, '').trim() || line.trim()
      return { id: uid(), text, startTime: null }
    })
}

function toLrc(lines: Line[]): string {
  return lines
    .filter(line => line.text.trim())
    .map(line => line.startTime !== null ? `[${fmt(line.startTime)}]${line.text}` : line.text)
    .join('\n')
}

const tooltipStyles = `
  .studio-tooltip {
    position: relative;
  }
  .studio-tooltip::after {
    content: attr(data-tooltip);
    position: absolute;
    bottom: 135%;
    left: 50%;
    transform: translateX(-50%) translateY(4px) scale(0.95);
    background-color: #121216;
    color: #e2e2e9;
    border: 1px solid #d4af37;
    padding: 6px 10px;
    border-radius: 6px;
    font-size: 0.72rem;
    font-weight: 500;
    white-space: nowrap;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.12s ease, transform 0.12s ease;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.6);
    z-index: 9999;
  }
  .studio-tooltip::before {
    content: '';
    position: absolute;
    bottom: 120%;
    left: 50%;
    transform: translateX(-50%) translateY(4px);
    border-width: 5px;
    border-style: solid;
    border-color: #d4af37 transparent transparent transparent;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.12s ease, transform 0.12s ease;
    z-index: 9999;
  }
  .studio-tooltip:hover::after,
  .studio-tooltip:hover::before {
    opacity: 1;
    transform: translateX(-50%) translateY(0) scale(1);
  }

  .studio-tooltip-bottom {
    position: relative;
  }
  .studio-tooltip-bottom::after {
    content: attr(data-tooltip);
    position: absolute;
    top: 135%;
    left: 50%;
    transform: translateX(-50%) translateY(-4px) scale(0.95);
    background-color: #121216;
    color: #e2e2e9;
    border: 1px solid #d4af37;
    padding: 6px 10px;
    border-radius: 6px;
    font-size: 0.72rem;
    font-weight: 500;
    white-space: nowrap;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.12s ease, transform 0.12s ease;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.6);
    z-index: 9999;
  }
  .studio-tooltip-bottom::before {
    content: '';
    position: absolute;
    top: 120%;
    left: 50%;
    transform: translateX(-50%) translateY(-4px);
    border-width: 5px;
    border-style: solid;
    border-color: transparent transparent #d4af37 transparent;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.12s ease, transform 0.12s ease;
    z-index: 9999;
  }
  .studio-tooltip-bottom:hover::after,
  .studio-tooltip-bottom:hover::before {
    opacity: 1;
    transform: translateX(-50%) translateY(0) scale(1);
  }
`;

export function LrcStudio({ audioFile, audioUrl, initialLrc, lang, draftKey: draftKeyProp, onClose, onSave }: Props) {
  const audioRef = useRef<HTMLAudioElement>(null)
  const activeLineRef = useRef<HTMLDivElement>(null)
  const listRef = useRef<HTMLDivElement>(null)

  const [lines, setLines] = useState<Line[]>(() => parseLrcLines(initialLrc || ''))
  const [activeIndex, setActiveIndex] = useState(0)
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
  const [rangeStartDraft, setRangeStartDraft] = useState('01:25.00')
  const [rangeEndDraft, setRangeEndDraft] = useState('01:35.00')
  const [rangeMode, setRangeMode] = useState(false)

  // Draft state
  const [draftBanner, setDraftBanner] = useState<DraftData | null>(null)
  const [draftStatus, setDraftStatus] = useState<'idle' | 'saving' | 'saved'>('idle')
  const draftTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const draftStatusTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null)
  const hasMountedRef = useRef(false)

  const isRecordingRef = useRef(false)
  const rangeModeRef = useRef(false)
  const rangeEndRef = useRef<number | null>(null)

  useEffect(() => { isRecordingRef.current = isRecording }, [isRecording])
  useEffect(() => { rangeModeRef.current = rangeMode }, [rangeMode])
  useEffect(() => { rangeEndRef.current = parseTime(rangeEndDraft) }, [rangeEndDraft])

  // On mount — check for existing draft
  useEffect(() => {
    if (!draftKeyProp) return
    const existing = loadDraft(draftKeyProp)
    if (existing && existing.lines.length > 0) {
      setDraftBanner(existing)
    }
    hasMountedRef.current = true
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  // Auto-save draft on lines change (debounced 2s)
  useEffect(() => {
    if (!draftKeyProp || !hasMountedRef.current) return
    // Don't auto-save while the resume banner is still showing
    if (draftBanner) return

    if (draftTimerRef.current) clearTimeout(draftTimerRef.current)
    setDraftStatus('saving')

    draftTimerRef.current = setTimeout(() => {
      saveDraft(draftKeyProp, {
        lines,
        activeIndex,
        timestamp: Date.now(),
        lang,
      })
      setDraftStatus('saved')
      if (draftStatusTimerRef.current) clearTimeout(draftStatusTimerRef.current)
      draftStatusTimerRef.current = setTimeout(() => setDraftStatus('idle'), 3000)
    }, 2000)

    return () => {
      if (draftTimerRef.current) clearTimeout(draftTimerRef.current)
    }
  }, [lines, activeIndex, draftKeyProp, lang, draftBanner])

  // Cleanup timers on unmount
  useEffect(() => {
    return () => {
      if (draftTimerRef.current) clearTimeout(draftTimerRef.current)
      if (draftStatusTimerRef.current) clearTimeout(draftStatusTimerRef.current)
    }
  }, [])

  const resumeDraft = useCallback(() => {
    if (!draftBanner) return
    setLines(draftBanner.lines.map(l => ({ ...l, id: uid() })))
    setActiveIndex(draftBanner.activeIndex)
    setDraftBanner(null)
  }, [draftBanner])

  const discardDraft = useCallback(() => {
    if (draftKeyProp) deleteDraft(draftKeyProp)
    setDraftBanner(null)
  }, [draftKeyProp])

  const handleDownloadDraft = useCallback(() => {
    if (!draftKeyProp) return
    // Save the current state first so the download is fresh
    saveDraft(draftKeyProp, { lines, activeIndex, timestamp: Date.now(), lang })
    exportDraftAsFile(draftKeyProp)
  }, [draftKeyProp, lines, activeIndex, lang])

  useEffect(() => {
    if (!audioFile) return
    const url = URL.createObjectURL(audioFile)
    setBlobUrl(url)
    return () => URL.revokeObjectURL(url)
  }, [audioFile])

  const audioSrc = blobUrl ?? audioUrl ?? ''

  useEffect(() => {
    const audio = audioRef.current
    if (!audio) return
    setAudioError(null)

    const onTime = () => setCurrentTime(audio.currentTime)
    const onDuration = () => {
      if (Number.isFinite(audio.duration)) setDuration(audio.duration)
    }
    const onPlay = () => setIsPlaying(true)
    const onPause = () => setIsPlaying(false)
    const onEnded = () => {
      setIsPlaying(false)
      setIsRecording(false)
    }
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

  useEffect(() => {
    if (audioRef.current) audioRef.current.playbackRate = playbackRate
  }, [playbackRate])

  const rangeStart = parseTime(rangeStartDraft)
  const rangeEnd = parseTime(rangeEndDraft)
  const rangeIsValid = rangeStart !== null && rangeEnd !== null && rangeEnd > rangeStart

  const playingIndex = useMemo(() => {
    let result = -1
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].startTime !== null && lines[i].startTime! <= currentTime) result = i
    }
    return result
  }, [lines, currentTime])

  const rangeLineIndexes = useMemo(() => {
    if (!rangeIsValid || rangeStart === null || rangeEnd === null) return []
    return lines
      .map((line, index) => ({ line, index }))
      .filter(({ line }) => line.startTime !== null && line.startTime >= rangeStart && line.startTime <= rangeEnd)
      .map(({ index }) => index)
  }, [lines, rangeIsValid, rangeStart, rangeEnd])

  useEffect(() => {
    activeLineRef.current?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }, [activeIndex])

  useEffect(() => {
    if (!isPlaying || isRecording) return
    const el = listRef.current?.querySelector('[data-playing="1"]') as HTMLElement | null
    el?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }, [playingIndex, isPlaying, isRecording])

  const seek = useCallback((t: number) => {
    if (audioRef.current) audioRef.current.currentTime = Math.max(0, Math.min(t, duration || Infinity))
  }, [duration])

  const seekAndPlay = useCallback((t: number) => {
    seek(t)
    audioRef.current?.play().catch(() => {})
  }, [seek])

  const mutateLines = (fn: (prev: Line[]) => Line[]) => setLines(fn)
  const updateLine = (id: string, patch: Partial<Line>) => {
    mutateLines(prev => prev.map(line => line.id === id ? { ...line, ...patch } : line))
  }
  const addLineAfter = (afterIndex: number) => {
    mutateLines(prev => {
      const next = [...prev]
      next.splice(afterIndex + 1, 0, { id: uid(), text: '', startTime: null })
      return next
    })
    setActiveIndex(afterIndex + 1)
  }
  const deleteLine = (index: number) => {
    mutateLines(prev => prev.filter((_, i) => i !== index))
    setActiveIndex(prev => Math.max(0, Math.min(prev, lines.length - 2)))
  }
  const moveLine = (index: number, direction: -1 | 1) => {
    const nextIndex = index + direction
    if (nextIndex < 0 || nextIndex >= lines.length) return
    mutateLines(prev => {
      const next = [...prev]
      ;[next[index], next[nextIndex]] = [next[nextIndex], next[index]]
      return next
    })
    setActiveIndex(nextIndex)
  }

  const stamp = useCallback((indexToStamp?: number) => {
    const audio = audioRef.current
    console.log('TimingStudio stamp called. audio:', audio, 'indexToStamp:', indexToStamp, 'activeIndex:', activeIndex)
    if (!audio) {
      console.warn('TimingStudio stamp aborted: audio is null/undefined')
      return
    }
    const stampedTime = audio.currentTime
    console.log('TimingStudio stampedTime:', stampedTime)
    let shouldStop = false

    const targetIndex = indexToStamp !== undefined ? indexToStamp : activeIndex

    setLines(prev => {
      const next = [...prev]
      if (targetIndex >= 0 && targetIndex < next.length) {
        next[targetIndex] = { ...next[targetIndex], startTime: stampedTime }
        console.log('TimingStudio updated line at index', targetIndex, 'to:', next[targetIndex])
      } else {
        console.warn('TimingStudio targetIndex out of bounds:', targetIndex, 'lines length:', next.length)
      }
      const following = next[targetIndex + 1]
      const end = rangeEndRef.current
      shouldStop = !!(rangeModeRef.current && end !== null && (!following || (following.startTime !== null && following.startTime > end)))
      return next
    })

    if (shouldStop) {
      setIsRecording(false)
      audio.pause()
      return
    }
    setActiveIndex(prev => Math.min(targetIndex + 1, lines.length - 1))
  }, [activeIndex, lines.length])

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (showImport || editTsId) return
      const tag = (e.target as HTMLElement)?.tagName
      const isInput = tag === 'INPUT' || tag === 'TEXTAREA'
      const audio = audioRef.current
      if (!audio) return

      if (e.code === 'Space' && !isInput) {
        e.preventDefault()
        if (isRecording) stamp()
        else audio.paused ? audio.play().catch(() => {}) : audio.pause()
      }
      if (e.key === 'Enter' && !isInput) {
        e.preventDefault()
        stamp()
        setTimeout(() => {
          const nextInput = document.getElementById(`lyric-input-${activeIndex + 1}`) as HTMLInputElement | null
          nextInput?.focus()
        }, 50)
      }
      if (e.key === 'ArrowDown' && !isInput) {
        e.preventDefault()
        const nextIndex = Math.min(activeIndex + 1, lines.length - 1)
        setActiveIndex(nextIndex)
        setTimeout(() => {
          const input = document.getElementById(`lyric-input-${nextIndex}`) as HTMLInputElement | null
          input?.focus()
        }, 50)
      }
      if (e.key === 'ArrowUp' && !isInput) {
        e.preventDefault()
        const prevIndex = Math.max(activeIndex - 1, 0)
        setActiveIndex(prevIndex)
        setTimeout(() => {
          const input = document.getElementById(`lyric-input-${prevIndex}`) as HTMLInputElement | null
          input?.focus()
        }, 50)
      }
      if (isInput) return
      if (e.code === 'Backspace' && isRecording) {
        e.preventDefault()
        setActiveIndex(prev => Math.max(prev - 1, 0))
      }
      if (e.key === 'Escape') {
        e.preventDefault()
        if (isRecording) setIsRecording(false)
        else onClose()
      }
      if (e.code === 'ArrowLeft') {
        e.preventDefault()
        seek(audio.currentTime - (e.shiftKey ? 5 : e.ctrlKey ? 0.5 : 2))
      }
      if (e.code === 'ArrowRight') {
        e.preventDefault()
        seek(audio.currentTime + (e.shiftKey ? 5 : e.ctrlKey ? 0.5 : 2))
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [stamp, isRecording, showImport, editTsId, seek, onClose, activeIndex, lines.length])

  const handleSeekBar = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!audioRef.current || duration === 0) return
    const rect = e.currentTarget.getBoundingClientRect()
    seek(((e.clientX - rect.left) / rect.width) * duration)
  }

  const openTsEdit = (e: React.MouseEvent, line: Line) => {
    e.stopPropagation()
    setEditTsId(line.id)
    setEditTsDraft(line.startTime !== null ? fmt(line.startTime) : '')
  }

  const commitTsEdit = (lineId: string) => {
    updateLine(lineId, { startTime: parseTime(editTsDraft) })
    setEditTsId(null)
  }

  const setRangeAroundPlayhead = () => {
    const start = Math.max(0, currentTime - 5)
    const end = duration > 0 ? Math.min(duration, currentTime + 5) : currentTime + 5
    setRangeStartDraft(fmt(start))
    setRangeEndDraft(fmt(end))
  }

  const clearRangeTimings = () => {
    if (!rangeIsValid || rangeStart === null || rangeEnd === null) return
    setLines(prev => prev.map(line => (
      line.startTime !== null && line.startTime >= rangeStart && line.startTime <= rangeEnd
        ? { ...line, startTime: null }
        : line
    )))
  }

  const firstLineForRange = () => {
    if (rangeLineIndexes.length > 0) return rangeLineIndexes[0]
    if (rangeStart === null) return activeIndex
    const nextTimed = lines.findIndex(line => line.startTime !== null && line.startTime >= rangeStart)
    return nextTimed === -1 ? activeIndex : nextTimed
  }

  const recordRange = () => {
    if (!rangeIsValid || rangeStart === null) return
    const first = firstLineForRange()
    clearRangeTimings()
    setActiveIndex(first)
    setRangeMode(true)
    seek(rangeStart)
    setIsRecording(true)
    audioRef.current?.play().catch(() => {})
  }

  const startFullRecording = () => {
    setRangeMode(false)
    setIsRecording(true)
    audioRef.current?.play().catch(() => {})
  }

  const timedCount = lines.filter(line => line.startTime !== null).length
  const progressPercent = duration > 0 ? (currentTime / duration) * 100 : 0

  return (
    <div style={{ position: 'fixed', inset: 0, zIndex: 1000, background: '#080808', display: 'flex', flexDirection: 'column', color: '#ccc' }}>
      <style dangerouslySetInnerHTML={{ __html: tooltipStyles }} />
      {audioSrc && <audio ref={audioRef} src={audioSrc} preload="metadata" crossOrigin="anonymous" style={{ display: 'none' }} />}

      <div style={{ background: '#0c0c0c', borderBottom: '1px solid #1e1e1e', padding: '10px 20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span style={{ color: '#fff', fontWeight: 700, fontSize: '1rem' }}>Timing Studio</span>
          <span style={{ color: '#4488bb', fontSize: '0.85rem' }}>({lang})</span>
          {isRecording && <span style={{ background: '#2a0808', color: '#ff6666', padding: '2px 8px', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 700 }}>{rangeMode ? 'Recording range' : 'Recording'}</span>}
          <span style={{ color: '#555', fontSize: '0.75rem' }}>{timedCount} / {lines.length} timed</span>
        </div>
        <div style={{ display: 'flex', gap: '6px' }}>
          <button className="secondary studio-tooltip-bottom" data-tooltip="Import plain text lyrics" style={{ fontSize: '0.8rem', padding: '5px 12px' }} onClick={() => setShowImport(value => !value)}>{showImport ? 'Done' : 'Import'}</button>
          {draftKeyProp && (
            <button className="secondary studio-tooltip-bottom" data-tooltip="Download current draft as JSON file" style={{ fontSize: '0.78rem', padding: '5px 10px' }} onClick={handleDownloadDraft}>↓ Draft</button>
          )}
          {draftStatus === 'saving' && <span style={{ color: '#888', fontSize: '0.72rem' }}>Saving…</span>}
          {draftStatus === 'saved' && <span style={{ color: '#5b8f63', fontSize: '0.72rem' }}>Draft saved ✓</span>}
          <button className="studio-tooltip-bottom" data-tooltip="Save timed lyrics & exit" style={{ padding: '5px 18px' }} onClick={() => { if (draftKeyProp) deleteDraft(draftKeyProp); onSave(toLrc(lines)); onClose() }} disabled={lines.length === 0}>Save</button>
          <button className="secondary studio-tooltip-bottom" data-tooltip="Close Timing Studio (keeps draft)" style={{ padding: '5px 10px' }} onClick={onClose}>Close</button>
        </div>
      </div>

      <div style={{ background: '#0f0f0f', borderBottom: '1px solid #1e1e1e', padding: '10px 20px', flexShrink: 0 }}>
        {!audioSrc ? (
          <p style={{ color: '#555', fontSize: '0.85rem', margin: 0 }}>No audio. Upload audio in the track editor first.</p>
        ) : audioError ? (
          <p style={{ color: '#cc4444', fontSize: '0.85rem', margin: 0 }}>{audioError}</p>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
            <button className="secondary studio-tooltip" data-tooltip="Stop audio (Reset playhead)" onClick={() => { if (audioRef.current) { audioRef.current.pause(); audioRef.current.currentTime = 0 } }} style={{ padding: '6px 10px', fontSize: '0.85rem' }}>Stop</button>
            <button className="secondary studio-tooltip" data-tooltip="Rewind 2 seconds (ArrowLeft)" onClick={() => seek(currentTime - 2)} style={{ padding: '6px 10px', fontSize: '0.8rem' }}>-2s</button>
            <button className="studio-tooltip" data-tooltip="Play / Pause audio (Space)" onClick={() => audioRef.current?.paused ? audioRef.current?.play().catch(() => {}) : audioRef.current?.pause()} style={{ minWidth: '80px', padding: '6px 12px' }}>{isPlaying ? 'Pause' : 'Play'}</button>
            <button className="secondary studio-tooltip" data-tooltip="Forward 2 seconds (ArrowRight)" onClick={() => seek(currentTime + 2)} style={{ padding: '6px 10px', fontSize: '0.8rem' }}>+2s</button>
            <span style={{ fontFamily: 'monospace', color: '#bbb', fontSize: '0.9rem', minWidth: '70px' }}>{fmt(currentTime)}</span>
            <div onClick={handleSeekBar} style={{ flex: 1, minWidth: '100px', height: '6px', background: '#1e1e1e', borderRadius: '3px', cursor: 'pointer', position: 'relative' }}>
              <div style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: `${progressPercent}%`, background: 'var(--accent, #4455cc)', borderRadius: '3px' }} />
            </div>
            <span style={{ fontFamily: 'monospace', color: '#666', fontSize: '0.9rem', minWidth: '70px' }}>{fmt(duration)}</span>
            {[0.5, 0.75, 1, 1.25].map(rate => (
              <button key={rate} className={playbackRate === rate ? 'studio-tooltip' : 'secondary studio-tooltip'} data-tooltip={`Set speed to ${rate}x`} style={{ padding: '4px 7px', fontSize: '0.72rem' }} onClick={() => setPlaybackRate(rate)}>{rate}x</button>
            ))}
            <button className="studio-tooltip" data-tooltip="Record timing stamps (Space or Enter to stamp row, Backspace to undo)" style={{ padding: '6px 14px' }} onClick={() => isRecording ? setIsRecording(false) : startFullRecording()}>{isRecording ? 'Stop Rec' : 'Record'}</button>
          </div>
        )}
      </div>

      <div style={{ background: '#0b0b0b', borderBottom: '1px solid #1e1e1e', padding: '10px 20px', display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap', flexShrink: 0 }}>
        <span style={{ color: '#888', fontSize: '0.82rem', fontWeight: 700 }}>Redo range</span>
        <input value={rangeStartDraft} onChange={e => setRangeStartDraft(e.target.value)} style={{ width: '86px', background: '#141414', color: '#ddd', border: '1px solid #303030', borderRadius: '4px', padding: '5px 7px', fontFamily: 'monospace' }} />
        <span style={{ color: '#555' }}>to</span>
        <input value={rangeEndDraft} onChange={e => setRangeEndDraft(e.target.value)} style={{ width: '86px', background: '#141414', color: '#ddd', border: '1px solid #303030', borderRadius: '4px', padding: '5px 7px', fontFamily: 'monospace' }} />
        <button className="secondary studio-tooltip" data-tooltip="Auto-populate times 5s before and after playhead" style={{ padding: '5px 10px', fontSize: '0.78rem' }} onClick={setRangeAroundPlayhead}>Use playhead +/-5s</button>
        <button className="secondary studio-tooltip" data-tooltip="Seek to range start and play" style={{ padding: '5px 10px', fontSize: '0.78rem' }} onClick={() => rangeStart !== null && seek(rangeStart)} disabled={!rangeIsValid}>Preview</button>
        <button className="secondary studio-tooltip" data-tooltip="Clear all timestamps within this range" style={{ padding: '5px 10px', fontSize: '0.78rem' }} onClick={clearRangeTimings} disabled={!rangeIsValid}>Clear timings</button>
        <button className="studio-tooltip" style={{ padding: '5px 12px', fontSize: '0.78rem' }} data-tooltip="Start recording timestamps for this range only" onClick={recordRange} disabled={!rangeIsValid || !audioSrc}>Record range</button>
        <span style={{ color: rangeIsValid ? '#666' : '#aa5555', fontSize: '0.75rem' }}>
          {rangeIsValid ? `${rangeLineIndexes.length} timed lines in range` : 'Enter times like 01:25.00'}
        </span>
      </div>

      {showImport && (
        <div style={{ background: '#0c0c0c', borderBottom: '1px solid #1e1e1e', padding: '12px 20px', flexShrink: 0 }}>
          <textarea style={{ width: '100%', minHeight: '120px', maxHeight: '200px', background: '#141414', color: '#ddd', border: '1px solid #2a2a2a', borderRadius: '6px', padding: '10px', fontSize: '0.9rem', lineHeight: 1.8, resize: 'vertical', fontFamily: 'monospace', outline: 'none' }} value={importText} onChange={e => setImportText(e.target.value)} placeholder="Paste plain lyrics or LRC here..." />
          <div style={{ display: 'flex', gap: '6px', marginTop: '8px' }}>
            <button onClick={() => { setLines(parseLrcLines(importText)); setActiveIndex(0); setShowImport(false) }} disabled={!importText.trim()}>Apply</button>
            <button className="secondary" onClick={() => setShowImport(false)}>Cancel</button>
          </div>
        </div>
      )}

      {/* Draft resume banner */}
      {draftBanner && (
        <div style={{ background: '#1a1810', borderBottom: '1px solid #2e2a1a', padding: '12px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '12px', flexShrink: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ color: '#d4af37', fontSize: '1rem' }}>📝</span>
            <span style={{ color: '#ccc', fontSize: '0.85rem' }}>Draft found from <strong style={{ color: '#d4af37' }}>{timeAgo(draftBanner.timestamp)}</strong> — {draftBanner.lines.length} lines, {draftBanner.lines.filter(l => l.startTime !== null).length} timed</span>
          </div>
          <div style={{ display: 'flex', gap: '6px', flexShrink: 0 }}>
            <button style={{ padding: '5px 14px', fontSize: '0.8rem' }} onClick={resumeDraft}>Resume</button>
            <button className="secondary" style={{ padding: '5px 10px', fontSize: '0.8rem', color: '#bb6666' }} onClick={discardDraft}>Discard</button>
          </div>
        </div>
      )}

      <div ref={listRef} style={{ flex: 1, overflowY: 'auto', paddingBottom: '20px' }}>
        {lines.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '80px 20px', color: '#555', fontSize: '0.9rem' }}>
            No lyrics. <span style={{ color: '#6688ff', cursor: 'pointer' }} onClick={() => setShowImport(true)}>Import or paste lyrics.</span>
          </div>
        ) : lines.map((line, index) => {
          const isActive = index === activeIndex
          const isPlayingLine = index === playingIndex
          const isTimed = line.startTime !== null
          const inRange = rangeLineIndexes.includes(index)
          let bg = 'transparent'
          let accentColor = 'transparent'
          if (isActive && isRecording) { bg = '#180808'; accentColor = '#882222' }
          else if (isActive) { bg = '#080818'; accentColor = '#2244aa' }
          else if (isPlayingLine) { bg = '#061006'; accentColor = '#1a4a1a' }
          else if (inRange) { bg = '#101008'; accentColor = '#5c5322' }

          const textColor = isActive ? '#ffffff' : isPlayingLine ? '#88dd88' : isTimed ? '#b0b0b0' : '#606060'
          const tsColor = isTimed ? (isActive ? '#8899ff' : isPlayingLine ? '#55bb55' : '#5b8f63') : '#3a3a3a'

          return (
            <div key={line.id} data-playing={isPlayingLine ? '1' : undefined} ref={isActive ? activeLineRef : undefined} onClick={() => { setActiveIndex(index); setTimeout(() => { const input = document.getElementById(`lyric-input-${index}`) as HTMLInputElement | null; input?.focus() }, 50) }} onDoubleClick={e => { if ((e.target as HTMLElement).tagName !== 'INPUT' && line.startTime !== null) seekAndPlay(line.startTime) }} style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '5px 20px 5px 16px', background: bg, borderLeft: `4px solid ${accentColor}`, cursor: 'default', minHeight: '36px' }}>
              <span style={{ fontFamily: 'monospace', fontSize: '0.68rem', color: '#444', minWidth: '24px', textAlign: 'right', flexShrink: 0 }}>{index + 1}</span>
              <span style={{ fontSize: '0.7rem', width: '10px', flexShrink: 0, color: isActive && isRecording ? '#cc4444' : isPlayingLine ? '#44aa44' : isTimed ? '#4a7a4a' : '#333' }}>{isActive && isRecording ? '*' : isPlayingLine ? '>' : isTimed ? 'ok' : '-'}</span>
              {editTsId === line.id ? (
                <input autoFocus value={editTsDraft} onChange={e => setEditTsDraft(e.target.value)} onBlur={() => commitTsEdit(line.id)} onKeyDown={e => { if (e.key === 'Enter') commitTsEdit(line.id); if (e.key === 'Escape') setEditTsId(null); e.stopPropagation() }} onClick={e => e.stopPropagation()} placeholder="00:00.00" style={{ fontFamily: 'monospace', fontSize: '0.8rem', width: '90px', flexShrink: 0, background: '#141428', color: '#aabbff', border: '1px solid #3344aa', borderRadius: '4px', padding: '2px 6px', outline: 'none' }} />
              ) : (
                <span onClick={e => openTsEdit(e, line)} onDoubleClick={e => e.stopPropagation()} title="Click to edit timestamp" style={{ fontFamily: 'monospace', fontSize: '0.8rem', minWidth: '90px', flexShrink: 0, color: tsColor, cursor: 'text', userSelect: 'none', padding: '2px 0' }}>{isTimed ? fmt(line.startTime!) : '--:--.--'}</span>
              )}
              <input
                id={`lyric-input-${index}`}
                value={line.text}
                onChange={e => { updateLine(line.id, { text: e.target.value }); setActiveIndex(index) }}
                onClick={e => { e.stopPropagation(); setActiveIndex(index) }}
                onDoubleClick={e => e.stopPropagation()}
                onKeyDown={e => {
                  if (e.key === 'Enter') {
                    e.preventDefault()
                    stamp(index)
                    if (index + 1 < lines.length) {
                      setTimeout(() => {
                        const nextInput = document.getElementById(`lyric-input-${index + 1}`) as HTMLInputElement | null
                        nextInput?.focus()
                      }, 50)
                    } else {
                      addLineAfter(index)
                      setTimeout(() => {
                        const nextInput = document.getElementById(`lyric-input-${index + 1}`) as HTMLInputElement | null
                        nextInput?.focus()
                      }, 50)
                    }
                  } else if (e.key === ' ' || e.code === 'Space') {
                    if (e.ctrlKey || e.metaKey || e.altKey || e.shiftKey) {
                      // Insert space at current cursor position
                      e.preventDefault()
                      const input = e.currentTarget
                      const start = input.selectionStart ?? 0
                      const end = input.selectionEnd ?? 0
                      const val = input.value
                      const newVal = val.slice(0, start) + ' ' + val.slice(end)
                      updateLine(line.id, { text: newVal })
                      setTimeout(() => {
                        input.selectionStart = input.selectionEnd = start + 1
                      }, 0)
                    } else {
                      // Play/pause audio
                      e.preventDefault()
                      const audio = audioRef.current
                      if (audio) {
                        audio.paused ? audio.play().catch(() => {}) : audio.pause()
                      }
                    }
                  } else if (e.key === 'ArrowDown') {
                    if (index + 1 < lines.length) {
                      e.preventDefault()
                      setActiveIndex(index + 1)
                      setTimeout(() => {
                        const nextInput = document.getElementById(`lyric-input-${index + 1}`) as HTMLInputElement | null
                        nextInput?.focus()
                      }, 50)
                    }
                  } else if (e.key === 'ArrowUp') {
                    if (index - 1 >= 0) {
                      e.preventDefault()
                      setActiveIndex(index - 1)
                      setTimeout(() => {
                        const prevInput = document.getElementById(`lyric-input-${index - 1}`) as HTMLInputElement | null
                        prevInput?.focus()
                      }, 50)
                    }
                  }
                }}
                placeholder="lyric..."
                style={{ flex: 1, background: 'transparent', outline: 'none', border: 'none', color: textColor, fontSize: '0.97rem', fontFamily: 'inherit', padding: '2px 0', cursor: 'text' }}
              />
              <div style={{ display: 'flex', gap: '2px', flexShrink: 0, opacity: isActive ? 1 : 0 }} onClick={e => e.stopPropagation()} onDoubleClick={e => e.stopPropagation()}>
                <button className="secondary studio-tooltip" data-tooltip="Move line up" style={{ padding: '2px 5px', fontSize: '0.7rem' }} onClick={() => moveLine(index, -1)} disabled={index === 0}>Up</button>
                <button className="secondary studio-tooltip" data-tooltip="Move line down" style={{ padding: '2px 5px', fontSize: '0.7rem' }} onClick={() => moveLine(index, 1)} disabled={index === lines.length - 1}>Down</button>
                <button className="secondary studio-tooltip" data-tooltip="Add empty line below" style={{ padding: '2px 5px', fontSize: '0.7rem' }} onClick={() => addLineAfter(index)}>Add</button>
                <button className="secondary studio-tooltip" data-tooltip="Delete this line" style={{ padding: '2px 5px', fontSize: '0.7rem', color: '#bb6666' }} onClick={() => deleteLine(index)}>Del</button>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
