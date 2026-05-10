import { useEffect } from 'react'
import type { Segment } from '../lib/transcript'

type Props = {
  audioRef: React.RefObject<HTMLAudioElement | null>
  segments: Segment[]
  activeIndex: number
  setActiveIndex: (idx: number) => void
  setSegments: (segments: Segment[]) => void
}

export function TimingTool({ audioRef, segments, activeIndex, setActiveIndex, setSegments }: Props) {
  useEffect(() => {
    const handler = (event: KeyboardEvent) => {
      const audio = audioRef.current
      if (!audio) return

      if (event.code === 'Space') {
        event.preventDefault()
        audio.paused ? audio.play() : audio.pause()
      }
      if (event.code === 'Enter') {
        event.preventDefault()
        if (activeIndex >= 0 && activeIndex < segments.length) {
          const next = [...segments]
          next[activeIndex] = { ...next[activeIndex], start: audio.currentTime }
          if (activeIndex > 0) {
            next[activeIndex - 1] = { ...next[activeIndex - 1], end: audio.currentTime }
          }
          setSegments(next)
          setActiveIndex(Math.min(activeIndex + 1, segments.length - 1))
        }
      }
      if (event.code === 'Backspace') {
        event.preventDefault()
        setActiveIndex(Math.max(activeIndex - 1, 0))
      }
      if (event.code === 'ArrowLeft') audio.currentTime = Math.max(audio.currentTime - (event.shiftKey ? 5 : event.ctrlKey ? 0.5 : 2), 0)
      if (event.code === 'ArrowRight') audio.currentTime = audio.currentTime + (event.shiftKey ? 5 : event.ctrlKey ? 0.5 : 2)
      if (event.key.toLowerCase() === 'f' && activeIndex >= 0) {
        const next = [...segments]
        next[activeIndex] = { ...next[activeIndex], flagged: !next[activeIndex].flagged }
        setSegments(next)
      }
    }

    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [audioRef, segments, activeIndex, setActiveIndex, setSegments])

  return null
}
