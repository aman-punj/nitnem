import { useState } from 'react'
import { parseLrc } from '../../lib/transcript'

type TranscriptLang = 'pa' | 'hi' | 'en'

type TranscriptEditorProps = {
  lrc: Record<TranscriptLang, string>
  json: Record<TranscriptLang, string>
  onChange: (lrc: Record<TranscriptLang, string>, json: Record<TranscriptLang, string>) => void
}

export function TranscriptEditor({ lrc, json, onChange }: TranscriptEditorProps) {
  const [activeTab, setActiveTab] = useState<TranscriptLang>('pa')

  const handleLrcChange = (val: string) => {
    const nextLrc = { ...lrc, [activeTab]: val }
    
    // Auto-parse to JSON
    try {
      const segments = parseLrc(val, activeTab)
      const nextJson = JSON.stringify({ segments }, null, 2)
      onChange(nextLrc, { ...json, [activeTab]: nextJson })
    } catch (err) {
      onChange(nextLrc, json)
    }
  }

  const handleJsonChange = (val: string) => {
    onChange(lrc, { ...json, [activeTab]: val })
  }

  const langNames: Record<TranscriptLang, string> = {
    pa: 'Punjabi',
    hi: 'Hindi',
    en: 'English'
  }

  const lineCount = lrc[activeTab].split('\n').filter(l => l.trim()).length

  return (
    <div className="stack">
      <div className="tabs">
        {(['pa', 'hi', 'en'] as TranscriptLang[]).map((lang) => (
          <div
            key={lang}
            className={`tab ${activeTab === lang ? 'active' : ''}`}
            onClick={() => setActiveTab(lang)}
          >
            {langNames[lang]}
          </div>
        ))}
      </div>

      <div className="stack fade-in" key={activeTab}>
        <div className="label-group">
          <div className="row spread">
            <label>LRC Input ({langNames[activeTab]})</label>
            <span className="info-text">{lineCount} lines</span>
          </div>
          <textarea
            className="monospace"
            value={lrc[activeTab]}
            onChange={(e) => handleLrcChange(e.target.value)}
            placeholder={`[00:00.00] Line of prayer in ${langNames[activeTab]}...`}
          />
        </div>

        <div className="label-group">
          <label>JSON Preview (Auto-generated)</label>
          <textarea
            className="monospace"
            value={json[activeTab]}
            onChange={(e) => handleJsonChange(e.target.value)}
            placeholder="JSON will appear here after parsing LRC..."
            style={{ minHeight: '100px', fontSize: '12px', opacity: 0.8 }}
          />
        </div>
      </div>
    </div>
  )
}
