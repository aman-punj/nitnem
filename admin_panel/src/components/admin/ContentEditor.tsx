import { useState, useEffect } from 'react'
import { slugifyTitleToId, nextTrackId, bumpVersion } from '../../lib/contentHelpers'
import { 
  ContentItem, 
  ContentType, 
  LocalizedTitles, 
  PrayerContentData, 
  PrayerTrack, 
  YoutubeLiveContentData 
} from '../../lib/contentTypes'
import { uploadAudioToCloudinary, uploadImageToCloudinary, uploadTranscriptJsonToCloudinary } from '../../lib/cloudinary'
import { parseLrc } from '../../lib/transcript'
import { AudioUploader } from './AudioUploader'
import { TranscriptEditor } from './TranscriptEditor'
import { TrackCard } from './TrackCard'
import { LrcStudio } from './LrcStudio'

type TranscriptLang = 'pa' | 'hi' | 'en'

type TrackEditorState = {
  mode: 'add' | 'edit'
  id: string
  title: string
  audioFile: File | null
  transcriptLrc: Record<TranscriptLang, string>
  transcriptJson: Record<TranscriptLang, string>
}

type ContentEditorProps = {
  item: ContentItem | null
  onSave: (item: ContentItem) => Promise<void>
  onClose: () => void
}

export function ContentEditor({ item, onSave, onClose }: ContentEditorProps) {
  const isEdit = !!item
  const [contentType, setContentType] = useState<ContentType>(item?.type ?? 'prayer')
  const [contentId, setContentId] = useState(item?.id ?? '')
  const [idTouched, setIdTouched] = useState(isEdit)
  const [titles, setTitles] = useState<LocalizedTitles>(item?.titles ?? { en: '', pa: '', hi: '' })
  const [enabled, setEnabled] = useState(item?.enabled ?? true)
  const [categoryId, setCategoryId] = useState(item?.categoryId ?? 'uncategorized')

  const [youtubeUrl, setYoutubeUrl] = useState(item?.type === 'youtube_live' ? item.youtube_url : '')
  const [youtubeThumbnail, setYoutubeThumbnail] = useState(item?.type === 'youtube_live' ? item.thumbnail ?? '' : '')
  const [iconUrl, setIconUrl] = useState(item?.type === 'prayer' ? (item as PrayerContentData).iconUrl ?? '' : '')
  const [iconUploadProgress, setIconUploadProgress] = useState<number | null>(null)

  const [tracks, setTracks] = useState<Record<string, PrayerTrack>>(
    item?.type === 'prayer' ? item.tracks : {}
  )
  const [activeTrackId, setActiveTrackId] = useState(
    item?.type === 'prayer' ? item.active_track : ''
  )

  const [trackEditor, setTrackEditor] = useState<TrackEditorState | null>(null)
  const [trackLoading, setTrackLoading] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [saveError, setSaveError] = useState('')
  const [uploadProgress, setUploadProgress] = useState<{ label: string; percent: number } | null>(null)
  const [lrcStudioLang, setLrcStudioLang] = useState<TranscriptLang | null>(null)

  useEffect(() => {
    if (!idTouched && !isEdit) {
      setContentId(slugifyTitleToId(titles.en))
    }
  }, [titles.en, idTouched, isEdit])

  const handleSaveMetadata = async () => {
    setSaveError('')
    if (!contentId) return setSaveError('ID is required')
    if (!titles.en || !titles.pa || !titles.hi) return setSaveError('All titles are required')

    setIsSaving(true)
    try {
      if (contentType === 'youtube_live') {
        const payload: YoutubeLiveContentData = {
          id: contentId,
          type: 'youtube_live',
          titles,
          youtube_url: youtubeUrl,
          thumbnail: youtubeThumbnail,
          categoryId,
          enabled,
          displayOrder: item?.displayOrder ?? 100,
        }
        await onSave(payload)
      } else {
        const payload: PrayerContentData = {
          id: contentId,
          type: 'prayer',
          titles,
          enabled,
          active_track: activeTrackId,
          categoryId,
          tracks,
          displayOrder: item?.displayOrder ?? 100,
          ...(iconUrl.trim() ? { iconUrl: iconUrl.trim() } : {}),
        }
        await onSave(payload)
      }
    } catch (err) {
      setSaveError(err instanceof Error ? err.message : 'Save failed')
    } finally {
      setIsSaving(false)
    }
  }

  function segmentsJsonToLrc(json: string): string {
    try {
      const { segments } = JSON.parse(json) as {
        segments: Array<{ startTime: unknown; pa?: string; hi?: string; en?: string }>
      }
      if (!Array.isArray(segments)) return ''
      return segments
        .map(s => {
          const text = (s.pa || s.hi || s.en || '').trim()
          if (!text) return null
          // Null / missing startTime → emit plain text so the studio can load it unformatted
          if (s.startTime === null || s.startTime === undefined) return text
          const t = Number(s.startTime)
          if (!isFinite(t) || isNaN(t)) return text
          const mins = Math.floor(t / 60)
          const sec = (t % 60).toFixed(2).padStart(5, '0')
          return `[${String(mins).padStart(2, '0')}:${sec}]${text}`
        })
        .filter(Boolean)
        .join('\n')
    } catch {
      return ''
    }
  }

  const openAddTrack = () => {
    const newId = nextTrackId(Object.keys(tracks))
    setTrackEditor({
      mode: 'add',
      id: newId,
      title: '',
      audioFile: null,
      transcriptLrc: { pa: '', hi: '', en: '' },
      transcriptJson: { pa: '', hi: '', en: '' },
    })
  }

  const openEditTrack = async (track: PrayerTrack) => {
    setTrackEditor({
      mode: 'edit',
      id: track.id,
      title: track.title,
      audioFile: null,
      transcriptLrc: { pa: '', hi: '', en: '' },
      transcriptJson: { pa: '', hi: '', en: '' },
    })
    setTrackLoading(true)

    const langs: TranscriptLang[] = ['pa', 'hi', 'en']
    const lrcResult: Record<TranscriptLang, string> = { pa: '', hi: '', en: '' }
    const jsonResult: Record<TranscriptLang, string> = { pa: '', hi: '', en: '' }

    await Promise.all(langs.map(async (lang) => {
      const url = track.transcripts[lang]?.url
      if (!url) return
      try {
        const res = await fetch(url)
        const text = await res.text()
        jsonResult[lang] = text
        lrcResult[lang] = segmentsJsonToLrc(text)
      } catch {
        // leave empty — user can re-paste if fetch fails
      }
    }))

    setTrackEditor(prev => prev ? { ...prev, transcriptLrc: lrcResult, transcriptJson: jsonResult } : prev)
    setTrackLoading(false)
  }

  const handleSaveTrack = async () => {
    if (!trackEditor) return
    setSaveError('')

    const existing = tracks[trackEditor.id]
    
    if (!trackEditor.title) return setSaveError('Track title required')
    // Removed mandatory audio requirement for Task 8

    setIsSaving(true)
    try {
      let audioUrl = existing?.audio?.url ?? ''
      const hasAudioChange = !!trackEditor.audioFile

      if (hasAudioChange && trackEditor.audioFile) {
        setUploadProgress({ label: 'Uploading Audio', percent: 0 })
        const res = await uploadAudioToCloudinary(trackEditor.audioFile, (p) => {
          setUploadProgress({ label: 'Uploading Audio', percent: p })
        })
        audioUrl = res.secureUrl
      }

      const nextTranscripts: PrayerTrack['transcripts'] = { ...existing?.transcripts }
      const langs: TranscriptLang[] = ['pa', 'hi', 'en']

      for (const lang of langs) {
        const json = trackEditor.transcriptJson[lang]
        if (json) {
          setUploadProgress({ label: `Uploading ${lang.toUpperCase()} Transcript`, percent: 0 })
          const res = await uploadTranscriptJsonToCloudinary(
            json,
            `${contentId}_${trackEditor.id}_${lang}.json`,
            (p) => setUploadProgress({ label: `Uploading ${lang.toUpperCase()} Transcript`, percent: p })
          )
          nextTranscripts[lang] = {
            url: res.secureUrl,
            version: bumpVersion(existing?.transcripts[lang]?.version, true)
          }
        }
      }

      const nextTrack: PrayerTrack = {
        id: trackEditor.id,
        title: trackEditor.title,
        audio: audioUrl ? {
          url: audioUrl,
          version: bumpVersion(existing?.audio?.version, hasAudioChange)
        } : existing?.audio,
        transcripts: nextTranscripts,
      }

      const nextTracks = { ...tracks, [nextTrack.id]: nextTrack }
      setTracks(nextTracks)
      if (!activeTrackId) setActiveTrackId(nextTrack.id)
      
      setTrackEditor(null)
      setUploadProgress(null)
    } catch (err) {
      setSaveError(err instanceof Error ? err.message : 'Track save failed')
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <div className="card fade-in">
      <div className="row spread" style={{ marginBottom: '24px' }}>
        <h2>{isEdit ? `Edit: ${titles.en}` : 'Create New Content'}</h2>
        <button className="secondary" onClick={onClose}>Close</button>
      </div>

      <div className="stack">
        {/* SECTION 1: METADATA */}
        <div className="card" style={{ background: '#fafafa' }}>
          <h3>1. Metadata</h3>
          <div className="grid">
            <div className="label-group">
              <label>Content Type</label>
              <select 
                value={contentType} 
                onChange={(e) => setContentType(e.target.value as ContentType)}
                disabled={isEdit}
              >
                <option value="prayer">Prayer</option>
                <option value="youtube_live">YouTube Live</option>
              </select>
            </div>
            <div className="label-group">
              <label>Content ID</label>
              <input 
                value={contentId} 
                onChange={(e) => { setContentId(e.target.value); setIdTouched(true); }}
                disabled={isEdit}
                placeholder="Unique identifier"
              />
            </div>
            <div className="label-group" style={{ flexDirection: 'row', alignItems: 'center', height: '100%' }}>
              <input 
                type="checkbox" 
                checked={enabled} 
                onChange={(e) => setEnabled(e.target.checked)}
                id="enabled-check"
              />
              <label htmlFor="enabled-check" style={{ marginBottom: 0, marginLeft: '8px' }}>Enabled</label>
            </div>
          </div>

          <div className="grid" style={{ marginTop: '16px' }}>
            <div className="label-group">
              <label>English Title</label>
              <input value={titles.en} onChange={(e) => setTitles({ ...titles, en: e.target.value })} />
            </div>
            <div className="label-group">
              <label>Punjabi Title</label>
              <input value={titles.pa} onChange={(e) => setTitles({ ...titles, pa: e.target.value })} />
            </div>
            <div className="label-group">
              <label>Hindi Title</label>
              <input value={titles.hi} onChange={(e) => setTitles({ ...titles, hi: e.target.value })} />
            </div>
          </div>

          <div className="grid" style={{ marginTop: '16px', borderTop: '1px solid #eee', paddingTop: '16px' }}>
            <div className="label-group">
              <label>Category ID</label>
              <input
                value={categoryId}
                onChange={(e) => setCategoryId(e.target.value)}
                placeholder="nitnem"
              />
            </div>
            {contentType === 'prayer' && (
              <div className="label-group">
                <label>Prayer Icon (Optional · PNG or SVG · shown in listing &amp; mini player)</label>
                <div className="row" style={{ gap: '12px', alignItems: 'center' }}>
                  {iconUrl && (
                    <img
                      src={iconUrl}
                      alt="icon preview"
                      style={{ width: 48, height: 48, objectFit: 'contain', borderRadius: 8, border: '1px solid #ddd', flexShrink: 0, background: '#f5f5f5', padding: '4px' }}
                    />
                  )}
                  <div className="stack" style={{ flex: 1, gap: '6px' }}>
                    <input
                      type="file"
                      accept="image/png,image/jpeg,image/webp,image/svg+xml"
                      style={{ fontSize: '0.85rem' }}
                      disabled={iconUploadProgress !== null}
                      onChange={async (e) => {
                        const file = e.target.files?.[0]
                        if (!file) return
                        setIconUploadProgress(0)
                        try {
                          const res = await uploadImageToCloudinary(file, (p) => setIconUploadProgress(p))
                          setIconUrl(res.secureUrl)
                        } catch {
                          setSaveError('Icon upload failed')
                        } finally {
                          setIconUploadProgress(null)
                          e.target.value = ''
                        }
                      }}
                    />
                    {iconUploadProgress !== null && (
                      <div className="upload-progress">
                        <div className="upload-progress-fill" style={{ width: `${iconUploadProgress}%` }} />
                      </div>
                    )}
                    {iconUrl && (
                      <button
                        className="secondary"
                        style={{ fontSize: '0.75rem', padding: '2px 8px', alignSelf: 'flex-start' }}
                        onClick={() => setIconUrl('')}
                      >
                        Remove icon
                      </button>
                    )}
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* SECTION 2: CONTENT SPECIFIC */}
        {contentType === 'youtube_live' ? (
          <div className="card" style={{ background: '#fafafa' }}>
            <h3>2. YouTube Live Details</h3>
            <div className="stack">
              <div className="label-group">
                <label>YouTube URL</label>
                <input value={youtubeUrl} onChange={(e) => setYoutubeUrl(e.target.value)} placeholder="https://youtube.com/live/..." />
              </div>
              <div className="label-group">
                <label>Thumbnail URL (Optional)</label>
                <input value={youtubeThumbnail} onChange={(e) => setYoutubeThumbnail(e.target.value)} placeholder="https://..." />
              </div>
            </div>
          </div>
        ) : (
          <div className="card" style={{ background: '#fafafa' }}>
            <div className="row spread">
              <h3>2. Tracks Management</h3>
              <button className="outline" onClick={openAddTrack}>+ Add Track</button>
            </div>
            
            <div className="stack" style={{ marginTop: '16px' }}>
              {Object.keys(tracks).length === 0 && (
                <div className="empty-state">No tracks yet. Add your first track to begin.</div>
              )}
              {Object.values(tracks).map(t => (
                <TrackCard 
                  key={t.id} 
                  track={t} 
                  isActive={activeTrackId === t.id}
                  onEdit={() => openEditTrack(t)}
                  onSetActive={() => setActiveTrackId(t.id)}
                />
              ))}
            </div>

            {/* SECTION 3: TRACK EDITOR */}
            {trackEditor && (
              <div className="card fade-in" style={{ marginTop: '24px', border: '2px solid var(--accent)' }}>
                <div className="row spread" style={{ marginBottom: '16px' }}>
                  <h4>{trackEditor.mode === 'add' ? 'Add New Track' : `Edit Track: ${trackEditor.id}`}</h4>
                  <button className="secondary" onClick={() => setTrackEditor(null)}>Cancel</button>
                </div>

                <div className="stack">
                  <div className="label-group">
                    <label>Track Title</label>
                    <input 
                      value={trackEditor.title} 
                      onChange={(e) => setTrackEditor({ ...trackEditor, title: e.target.value })}
                      placeholder="e.g. Female Voice, Fast Version"
                    />
                  </div>

                  <AudioUploader onFileSelected={(f) => setTrackEditor({ ...trackEditor, audioFile: f })} />

                  <div className="section-divider" />

                  <div className="row spread">
                    <h4 style={{ margin: 0 }}>
                      Transcripts
                      {trackLoading && <span className="info-text" style={{ marginLeft: '10px', fontWeight: 400 }}>Loading…</span>}
                    </h4>
                    <div className="row" style={{ gap: '8px' }}>
                      {(['pa', 'hi', 'en'] as TranscriptLang[]).map(lang => (
                        <button
                          key={lang}
                          className="secondary"
                          style={{ fontSize: '0.8rem', padding: '4px 10px' }}
                          disabled={trackLoading}
                          onClick={() => setLrcStudioLang(lang)}
                        >
                          {lang === 'pa' ? 'ਪੰਜਾਬੀ' : lang === 'hi' ? 'हिन्दी' : 'EN'} Studio
                        </button>
                      ))}
                    </div>
                  </div>

                  <TranscriptEditor
                    lrc={trackEditor.transcriptLrc}
                    json={trackEditor.transcriptJson}
                    onChange={(l, j) => setTrackEditor({ ...trackEditor, transcriptLrc: l, transcriptJson: j })}
                  />

                  {lrcStudioLang && (
                    <LrcStudio
                      audioFile={trackEditor.audioFile}
                      audioUrl={tracks[trackEditor.id]?.audio?.url}
                      initialLrc={trackEditor.transcriptLrc[lrcStudioLang]}
                      lang={lrcStudioLang}
                      onClose={() => setLrcStudioLang(null)}
                      onSave={(lrc) => {
                        if (!trackEditor) return
                        const nextLrc = { ...trackEditor.transcriptLrc, [lrcStudioLang]: lrc }
                        try {
                          const segments = parseLrc(lrc, lrcStudioLang)
                          const nextJson = { ...trackEditor.transcriptJson, [lrcStudioLang]: JSON.stringify({ segments }, null, 2) }
                          setTrackEditor({ ...trackEditor, transcriptLrc: nextLrc, transcriptJson: nextJson })
                        } catch {
                          setTrackEditor({ ...trackEditor, transcriptLrc: nextLrc })
                        }
                      }}
                    />
                  )}

                  {uploadProgress && (
                    <div className="stack" style={{ gap: '4px' }}>
                      <div className="row spread">
                        <span className="info-text">{uploadProgress.label}</span>
                        <span className="info-text">{uploadProgress.percent}%</span>
                      </div>
                      <div className="upload-progress">
                        <div className="upload-progress-fill" style={{ width: `${uploadProgress.percent}%` }} />
                      </div>
                    </div>
                  )}

                  <button 
                    style={{ width: '100%', marginTop: '12px' }} 
                    onClick={handleSaveTrack}
                    disabled={isSaving}
                  >
                    {isSaving ? 'Processing...' : 'Save Track Details'}
                  </button>
                </div>
              </div>
            )}
          </div>
        )}

        {saveError && <p className="error-text">{saveError}</p>}

        <div className="row spread" style={{ marginTop: '24px' }}>
          <button className="secondary" onClick={onClose} disabled={isSaving}>Discard Changes</button>
          <button onClick={handleSaveMetadata} disabled={isSaving || !!trackEditor}>
            {isSaving ? 'Saving...' : 'Save All Content Changes'}
          </button>
        </div>
      </div>
    </div>
  )
}
