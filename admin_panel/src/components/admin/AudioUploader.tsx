import { useRef, useState } from 'react'
import { FFmpeg } from '@ffmpeg/ffmpeg'
import { fetchFile, toBlobURL } from '@ffmpeg/util'

type AudioUploaderProps = {
  onFileSelected: (file: File) => void
  onProgress?: (percent: number) => void
}

export function AudioUploader({ onFileSelected }: AudioUploaderProps) {
  const [isCompressing, setIsCompressing] = useState(false)
  const [progress, setProgress] = useState(0)
  const [stats, setStats] = useState<{ original: number; compressed: number } | null>(null)
  const [error, setError] = useState<string | null>(null)
  const ffmpegRef = useRef<FFmpeg | null>(null)

  const loadFFmpeg = async () => {
    const baseURL = 'https://unpkg.com/@ffmpeg/core@0.12.6/dist/esm'
    const ffmpeg = new FFmpeg()
    ffmpeg.on('progress', ({ progress }) => {
      setProgress(Math.round(progress * 100))
    })
    await ffmpeg.load({
      coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript'),
      wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm'),
    })
    ffmpegRef.current = ffmpeg
  }

  const compressAudio = async (file: File) => {
    setIsCompressing(true)
    setProgress(0)
    setError(null)
    try {
      if (!ffmpegRef.current) {
        await loadFFmpeg()
      }
      const ffmpeg = ffmpegRef.current!
      const inputName = 'input.mp3'
      const outputName = 'output.mp3'

      await ffmpeg.writeFile(inputName, await fetchFile(file))
      
      // Optimize for spoken prayer audio: mono, 48kbps
      await ffmpeg.exec([
        '-i', inputName,
        '-ac', '1',
        '-b:a', '48k',
        outputName
      ])

      const data = await ffmpeg.readFile(outputName)
      const compressedBlob = new Blob([data], { type: 'audio/mp3' })
      const compressedFile = new File([compressedBlob], file.name, { type: 'audio/mp3' })

      setStats({
        original: file.size,
        compressed: compressedFile.size
      })
      onFileSelected(compressedFile)
    } catch (err) {
      console.error('Compression error:', err)
      setError('Failed to compress audio. Uploading original file instead.')
      onFileSelected(file)
    } finally {
      setIsCompressing(false)
    }
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    // If file is already small (e.g. < 2MB), just select it
    if (file.size < 2 * 1024 * 1024) {
      onFileSelected(file)
      setStats(null)
      return
    }

    void compressAudio(file)
  }

  return (
    <div className="stack">
      <div className="label-group">
        <label>Audio File (MP3)</label>
        <input 
          type="file" 
          accept="audio/mpeg,.mp3" 
          onChange={handleFileChange}
          disabled={isCompressing}
        />
      </div>

      {isCompressing && (
        <div className="fade-in">
          <p className="info-text">Compressing audio for better performance...</p>
          <div className="upload-progress">
            <div className="upload-progress-fill" style={{ width: `${progress}%` }}></div>
          </div>
          <p className="info-text" style={{ textAlign: 'right' }}>{progress}%</p>
        </div>
      )}

      {stats && (
        <div className="info-text success-text fade-in">
          Compressed: {(stats.original / 1024 / 1024).toFixed(2)}MB → {(stats.compressed / 1024 / 1024).toFixed(2)}MB
        </div>
      )}

      {error && <p className="error-text">{error}</p>}
    </div>
  )
}
