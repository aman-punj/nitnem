import { useEffect, useMemo, useState } from 'react'

import { uploadAudioToCloudinary, uploadTranscriptJsonToCloudinary } from '../lib/cloudinary'
import { bumpVersion, nextTrackId, slugifyTitleToId } from '../lib/contentHelpers'
import { fetchContentList, upsertContentItem } from '../lib/contentService'
import { contentDisplayTitle, type ContentItem, type ContentType, type LocalizedTitles, type PrayerContentData, type PrayerTrack, type YoutubeLiveContentData } from '../lib/contentTypes'
import {
  initAuthPersistence,
  isAllowedAdminEmail,
  onAdminAuthChange,
  signInAdminWithGoogle,
  signOutAdmin,
} from '../lib/firebase'
import { parseLrc } from '../lib/transcript'

type AuthStatus = 'checking' | 'signed_out' | 'signed_in' | 'error'
type TranscriptLang = 'pa' | 'hi' | 'en'

type TrackEditorState = {
  mode: 'add' | 'edit'
  id: string
  title: string
  audioFile: File | null
  transcriptLrc: Record<TranscriptLang, string>
  transcriptJson: Record<TranscriptLang, string>
  baselineTranscriptJson: Record<TranscriptLang, string>
}

function emptyTitles(): LocalizedTitles {
  return { en: '', pa: '', hi: '' }
}

function emptyTrackState(mode: 'add' | 'edit', trackId = ''): TrackEditorState {
  return {
    mode,
    id: trackId,
    title: '',
    audioFile: null,
    transcriptLrc: { pa: '', hi: '', en: '' },
    transcriptJson: { pa: '', hi: '', en: '' },
    baselineTranscriptJson: { pa: '', hi: '', en: '' },
  }
}

function emptyUploadState() {
  return {
    loading: false,
    audioProgress: 0,
    transcriptProgress: { pa: 0, hi: 0, en: 0 } as Record<TranscriptLang, number>,
    message: '',
    error: '',
  }
}

export function AdminApp() {
  const [authStatus, setAuthStatus] = useState<AuthStatus>('checking')
  const [authUserEmail, setAuthUserEmail] = useState('')
  const [authMessage, setAuthMessage] = useState('')
  const [authLoading, setAuthLoading] = useState(false)

  const [items, setItems] = useState<ContentItem[]>([])
  const [loadingItems, setLoadingItems] = useState(false)
  const [itemsError, setItemsError] = useState('')
  const [search, setSearch] = useState('')

  const [editorOpen, setEditorOpen] = useState(false)
  const [editorMode, setEditorMode] = useState<'add' | 'edit'>('add')
  const [contentType, setContentType] = useState<ContentType>('prayer')
  const [contentId, setContentId] = useState('')
  const [idTouched, setIdTouched] = useState(false)
  const [titles, setTitles] = useState<LocalizedTitles>(emptyTitles())
  const [enabled, setEnabled] = useState(true)

  const [youtubeUrl, setYoutubeUrl] = useState('')
  const [youtubeThumbnail, setYoutubeThumbnail] = useState('')

  const [editingPrayer, setEditingPrayer] = useState<PrayerContentData | null>(null)
  const [activeTrackDraft, setActiveTrackDraft] = useState('')

  const [trackEditor, setTrackEditor] = useState<TrackEditorState | null>(null)
  const [activeTranscriptTab, setActiveTranscriptTab] = useState<TranscriptLang>('pa')

  const [savingContent, setSavingContent] = useState(false)
  const [saveMessage, setSaveMessage] = useState('')
  const [saveError, setSaveError] = useState('')

  const [uploadState, setUploadState] = useState(emptyUploadState())

  const isAuthed = authStatus === 'signed_in'

  const filteredItems = useMemo(() => {
    const q = search.trim().toLowerCase()
    if (!q) return items
    return items.filter((item) => {
      const t = contentDisplayTitle(item).toLowerCase()
      return t.includes(q) || item.id.toLowerCase().includes(q)
    })
  }, [items, search])

  useEffect(() => {
    let unsub = () => {}

    void (async () => {
      try {
        await initAuthPersistence()
        unsub = onAdminAuthChange((user) => {
          if (!user) {
            setAuthStatus('signed_out')
            setAuthUserEmail('')
            return
          }
          if (!isAllowedAdminEmail(user.email)) {
            setAuthStatus('error')
            setAuthMessage('Signed in account is not authorized for admin access.')
            setAuthUserEmail(user.email ?? '')
            return
          }
          setAuthStatus('signed_in')
          setAuthUserEmail(user.email ?? '')
          setAuthMessage('')
        })
      } catch (error) {
        setAuthStatus('error')
        setAuthMessage(error instanceof Error ? error.message : 'Failed to initialize authentication.')
      }
    })()

    return () => unsub()
  }, [])

  useEffect(() => {
    if (idTouched) return
    const slug = slugifyTitleToId(titles.en)
    setContentId(slug)
  }, [titles.en, idTouched])

  useEffect(() => {
    if (!isAuthed) return
    void loadContentList()
  }, [isAuthed])

  async function loadContentList(): Promise<void> {
    setLoadingItems(true)
    setItemsError('')
    try {
      const list = await fetchContentList()
      setItems(list)
    } catch (error) {
      setItemsError(error instanceof Error ? error.message : 'Failed to load content list.')
    } finally {
      setLoadingItems(false)
    }
  }

  function resetEditorState(): void {
    setEditorOpen(false)
    setEditorMode('add')
    setContentType('prayer')
    setContentId('')
    setIdTouched(false)
    setTitles(emptyTitles())
    setEnabled(true)
    setYoutubeUrl('')
    setYoutubeThumbnail('')
    setEditingPrayer(null)
    setActiveTrackDraft('')
    setTrackEditor(null)
    setActiveTranscriptTab('pa')
    setSaveMessage('')
    setSaveError('')
    setUploadState(emptyUploadState())
  }

  function openAddEditor(): void {
    resetEditorState()
    setEditorOpen(true)
    setEditorMode('add')
  }

  function openEditEditor(item: ContentItem): void {
    resetEditorState()
    setEditorOpen(true)
    setEditorMode('edit')
    setContentType(item.type)
    setContentId(item.id)
    setIdTouched(true)
    setTitles(item.titles)
    setEnabled(item.enabled)

    if (item.type === 'prayer') {
      setEditingPrayer(item)
      setActiveTrackDraft(item.active_track)
    } else {
      setYoutubeUrl(item.youtube_url)
      setYoutubeThumbnail(item.thumbnail ?? '')
    }
  }

  function openTrackEditor(mode: 'add' | 'edit', track?: PrayerTrack): void {
    if (!editingPrayer) return

    if (mode === 'add') {
      const generatedTrackId = nextTrackId(Object.keys(editingPrayer.tracks))
      setTrackEditor(emptyTrackState('add', generatedTrackId))
      setActiveTranscriptTab('pa')
      return
    }

    if (track) {
      const next = emptyTrackState('edit', track.id)
      next.title = track.title
      ;(['pa', 'hi', 'en'] as TranscriptLang[]).forEach((lang) => {
        const url = track.transcripts[lang]?.url
        if (url) {
          next.baselineTranscriptJson[lang] = url
        }
      })
      setTrackEditor(next)
      setActiveTranscriptTab('pa')
    }
  }

  function parseCurrentLrcToJson(lang: TranscriptLang): void {
    if (!trackEditor) return
    const segments = parseLrc(trackEditor.transcriptLrc[lang])
    const nextJson = JSON.stringify({ segments }, null, 2)
    setTrackEditor({
      ...trackEditor,
      transcriptJson: { ...trackEditor.transcriptJson, [lang]: nextJson },
    })
  }

  function onAudioFileSelected(file: File | null): void {
    if (!trackEditor) return
    const nextTitle = trackEditor.title || (file?.name ? file.name.replace(/\.mp3$/i, '') : '')
    setTrackEditor({
      ...trackEditor,
      audioFile: file,
      title: nextTitle,
    })
  }

  async function onSignIn(): Promise<void> {
    setAuthLoading(true)
    setAuthMessage('')
    try {
      const user = await signInAdminWithGoogle()
      setAuthStatus('signed_in')
      setAuthUserEmail(user.email ?? '')
    } catch (error) {
      setAuthStatus('error')
      setAuthMessage(error instanceof Error ? error.message : 'Google sign-in failed.')
    } finally {
      setAuthLoading(false)
    }
  }

  async function onLogout(): Promise<void> {
    setAuthLoading(true)
    setAuthMessage('')
    try {
      await signOutAdmin()
      setAuthStatus('signed_out')
      setAuthUserEmail('')
      resetEditorState()
    } catch (error) {
      setAuthStatus('error')
      setAuthMessage(error instanceof Error ? error.message : 'Logout failed.')
    } finally {
      setAuthLoading(false)
    }
  }

  async function saveContentMetadataOnly(): Promise<void> {
    setSaveError('')
    setSaveMessage('')

    if (!contentId.trim()) {
      setSaveError('Content id is required.')
      return
    }
    if (!titles.en.trim() || !titles.pa.trim() || !titles.hi.trim()) {
      setSaveError('English, Punjabi, and Hindi titles are required.')
      return
    }

    setSavingContent(true)

    try {
      if (contentType === 'youtube_live') {
        if (!youtubeUrl.trim()) {
          throw new Error('youtube_live requires YouTube URL.')
        }

        const payload: YoutubeLiveContentData = {
          id: contentId.trim(),
          type: 'youtube_live',
          titles,
          youtube_url: youtubeUrl.trim(),
          thumbnail: youtubeThumbnail.trim(),
          enabled,
        }

        await upsertContentItem(payload)
        setSaveMessage('youtube_live content saved.')
      } else {
        const prayer: PrayerContentData = {
          id: contentId.trim(),
          type: 'prayer',
          titles,
          enabled,
          active_track: activeTrackDraft || editingPrayer?.active_track || '',
          tracks: editingPrayer?.tracks ?? {},
        }

        await upsertContentItem(prayer)
        setEditingPrayer(prayer)
        setSaveMessage('Prayer metadata saved.')
      }

      await loadContentList()
    } catch (error) {
      setSaveError(error instanceof Error ? error.message : 'Failed to save content metadata.')
    } finally {
      setSavingContent(false)
    }
  }

  async function saveTrack(): Promise<void> {
    if (!editingPrayer || !trackEditor) return

    setSaveError('')
    setSaveMessage('')

    const existing = editingPrayer.tracks[trackEditor.id]
    const isFirstTrack = Object.keys(editingPrayer.tracks).length === 0 && trackEditor.mode === 'add'

    const changedTranscriptLangs = (['pa', 'hi', 'en'] as TranscriptLang[]).filter((lang) => {
      const text = trackEditor.transcriptJson[lang].trim()
      return text.length > 0
    })

    if (!trackEditor.title.trim()) {
      setSaveError('Track title is required.')
      return
    }

    if (isFirstTrack && !trackEditor.audioFile) {
      setSaveError('First track requires audio upload.')
      return
    }

    if (isFirstTrack && changedTranscriptLangs.length === 0) {
      setSaveError('First track requires at least one transcript (Punjabi recommended).')
      return
    }

    setUploadState({
      loading: true,
      audioProgress: 0,
      transcriptProgress: { pa: 0, hi: 0, en: 0 },
      message: 'Uploading track assets before metadata update...',
      error: '',
    })

    try {
      let audioUrl = existing?.audio?.url ?? ''
      const hasAudioChange = trackEditor.audioFile !== null
      if (hasAudioChange && trackEditor.audioFile) {
        const uploadedAudio = await uploadAudioToCloudinary(trackEditor.audioFile, (percent) => {
          setUploadState((prev) => ({ ...prev, audioProgress: percent }))
        })
        audioUrl = uploadedAudio.secureUrl
      }

      const nextTranscripts: PrayerTrack['transcripts'] = {
        pa: existing?.transcripts.pa,
        hi: existing?.transcripts.hi,
        en: existing?.transcripts.en,
      }

      for (const lang of changedTranscriptLangs) {
        const uploaded = await uploadTranscriptJsonToCloudinary(
          trackEditor.transcriptJson[lang],
          `${editingPrayer.id}_${trackEditor.id}_${lang}.json`,
          (percent) => {
            setUploadState((prev) => ({
              ...prev,
              transcriptProgress: { ...prev.transcriptProgress, [lang]: percent },
            }))
          },
        )

        const previous = existing?.transcripts[lang]
        nextTranscripts[lang] = {
          url: uploaded.secureUrl,
          version: bumpVersion(previous?.version, true),
        }
      }

      const nextTrack: PrayerTrack = {
        id: trackEditor.id,
        title: trackEditor.title.trim(),
        audio: audioUrl
          ? {
              url: audioUrl,
              version: bumpVersion(existing?.audio?.version, hasAudioChange),
            }
          : existing?.audio,
        transcripts: {
          pa: nextTranscripts.pa,
          hi: nextTranscripts.hi,
          en: nextTranscripts.en,
        },
        duration: existing?.duration,
      }

      const nextTracks: Record<string, PrayerTrack> = {
        ...editingPrayer.tracks,
        [nextTrack.id]: nextTrack,
      }

      const shouldAutoSetActive = !editingPrayer.active_track
      const nextActiveTrack = shouldAutoSetActive ? nextTrack.id : activeTrackDraft || editingPrayer.active_track

      const payload: PrayerContentData = {
        ...editingPrayer,
        active_track: nextActiveTrack,
        tracks: nextTracks,
      }

      await upsertContentItem(payload)
      setEditingPrayer(payload)
      setActiveTrackDraft(payload.active_track)
      setTrackEditor(null)
      setUploadState((prev) => ({ ...prev, loading: false, message: 'Track saved successfully.' }))
      setSaveMessage('Track saved.')
      await loadContentList()
    } catch (error) {
      setUploadState((prev) => ({
        ...prev,
        loading: false,
        error: error instanceof Error ? error.message : 'Track upload failed.',
      }))
      setSaveError(error instanceof Error ? error.message : 'Failed to save track.')
    }
  }

  async function setTrackAsActive(trackId: string): Promise<void> {
    if (!editingPrayer) return

    try {
      const payload: PrayerContentData = {
        ...editingPrayer,
        active_track: trackId,
      }
      await upsertContentItem(payload)
      setEditingPrayer(payload)
      setActiveTrackDraft(trackId)
      setSaveMessage(`Active track set to ${trackId}.`)
      await loadContentList()
    } catch (error) {
      setSaveError(error instanceof Error ? error.message : 'Failed to set active track.')
    }
  }

  return (
    <div className="app">
      <h1>Nitnem Admin Panel</h1>

      <div className="card">
        <h3>Authentication</h3>
        {authStatus === 'checking' && <p>Checking existing admin session...</p>}
        {authStatus !== 'checking' && (
          <div className="row">
            {!isAuthed && (
              <button onClick={() => void onSignIn()} disabled={authLoading}>
                {authLoading ? 'Signing In...' : 'Sign in with Google'}
              </button>
            )}
            {isAuthed && (
              <>
                <span>Signed in as: {authUserEmail}</span>
                <button onClick={() => void onLogout()} disabled={authLoading}>
                  {authLoading ? 'Logging Out...' : 'Logout'}
                </button>
              </>
            )}
          </div>
        )}
        {authMessage && <p>{authMessage}</p>}
      </div>

      {!isAuthed && <div className="card"><p>Sign in with an allowlisted admin email to manage content.</p></div>}

      {isAuthed && (
        <>
          <div className="card">
            <div className="row spread">
              <h3>Content Dashboard</h3>
              <div className="row">
                <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search by title or id" />
                <button onClick={openAddEditor}>Add Content</button>
                <button onClick={() => void loadContentList()} disabled={loadingItems}>Reload</button>
              </div>
            </div>

            {loadingItems && <p>Loading content...</p>}
            {itemsError && <p>{itemsError}</p>}
            {!loadingItems && filteredItems.length === 0 && <p>No content found. Click Add Content to create one.</p>}

            {filteredItems.map((item) => {
              const activeTrack = item.type === 'prayer' ? item.tracks[item.active_track] : undefined
              return (
                <div key={item.id} className="content-item">
                  <div className="row spread">
                    <div>
                      <strong>{item.titles.en}</strong>
                      <p>Punjabi: {item.titles.pa}</p>
                      <p>Hindi: {item.titles.hi}</p>
                      <p>Type: {item.type}</p>
                      <p>Enabled: {item.enabled ? 'Yes' : 'No'}</p>
                      <p>Active Track: {item.type === 'prayer' ? item.active_track : '-'}</p>
                      <p>Track Count: {item.type === 'prayer' ? Object.keys(item.tracks).length : '-'}</p>
                      <p>
                        Version Info: {item.type === 'prayer'
                          ? `audio v${activeTrack?.audio?.version ?? '-'}, pa v${activeTrack?.transcripts.pa?.version ?? '-'}, hi v${activeTrack?.transcripts.hi?.version ?? '-'}, en v${activeTrack?.transcripts.en?.version ?? '-'}`
                          : '-'}
                      </p>
                    </div>
                    <button onClick={() => openEditEditor(item)}>Edit</button>
                  </div>
                </div>
              )
            })}
          </div>

          {editorOpen && (
            <div className="card">
              <h3>{editorMode === 'add' ? 'Create Content' : `Edit Content: ${titles.en || contentId}`}</h3>

              <div className="row">
                <select value={contentType} onChange={(e) => setContentType(e.target.value as ContentType)} disabled={editorMode === 'edit'}>
                  <option value="prayer">prayer</option>
                  <option value="youtube_live">youtube_live</option>
                </select>
                <label>
                  <input type="checkbox" checked={enabled} onChange={(e) => setEnabled(e.target.checked)} /> Enabled
                </label>
              </div>

              <div className="row">
                <input
                  value={titles.en}
                  onChange={(e) => setTitles((prev) => ({ ...prev, en: e.target.value }))}
                  placeholder="English title"
                />
                <input
                  value={titles.pa}
                  onChange={(e) => setTitles((prev) => ({ ...prev, pa: e.target.value }))}
                  placeholder="Punjabi title"
                />
                <input
                  value={titles.hi}
                  onChange={(e) => setTitles((prev) => ({ ...prev, hi: e.target.value }))}
                  placeholder="Hindi title"
                />
              </div>

              <div className="row">
                <input
                  value={contentId}
                  onChange={(e) => {
                    setIdTouched(true)
                    setContentId(e.target.value)
                  }}
                  placeholder="content_id (auto-generated, editable)"
                  disabled={editorMode === 'edit'}
                />
              </div>

              {contentType === 'youtube_live' && (
                <div className="row">
                  <input value={youtubeUrl} onChange={(e) => setYoutubeUrl(e.target.value)} placeholder="YouTube URL" />
                  <input value={youtubeThumbnail} onChange={(e) => setYoutubeThumbnail(e.target.value)} placeholder="Thumbnail URL (optional)" />
                </div>
              )}

              {contentType === 'prayer' && editingPrayer && (
                <>
                  <h4>Prayer Details</h4>
                  <div className="row">
                    <input
                      value={activeTrackDraft}
                      onChange={(e) => setActiveTrackDraft(e.target.value)}
                      placeholder="Active track id"
                    />
                    <button onClick={() => openTrackEditor('add')}>Add Track</button>
                  </div>

                  {Object.values(editingPrayer.tracks).length === 0 && <p>No tracks yet. Add first track.</p>}

                  {Object.values(editingPrayer.tracks).map((track) => (
                    <div key={track.id} className="content-item">
                      <div className="row spread">
                        <div>
                          <strong>{track.title}</strong>
                          <p>ID: {track.id}</p>
                          <p>Active: {editingPrayer.active_track === track.id ? 'Yes' : 'No'}</p>
                          <p>Audio version: {track.audio?.version ?? '-'}</p>
                          <p>Transcript versions: pa {track.transcripts.pa?.version ?? '-'}, hi {track.transcripts.hi?.version ?? '-'}, en {track.transcripts.en?.version ?? '-'}</p>
                        </div>
                        <div className="row">
                          <button onClick={() => setTrackAsActive(track.id)} disabled={editingPrayer.active_track === track.id}>Set Active</button>
                          <button onClick={() => openTrackEditor('edit', track)}>Edit Track</button>
                        </div>
                      </div>
                    </div>
                  ))}

                  {trackEditor && (
                    <div className="card">
                      <h4>{trackEditor.mode === 'add' ? 'Add Track' : `Edit Track: ${trackEditor.id}`}</h4>
                      <div className="row">
                        <input value={trackEditor.id} disabled />
                        <input
                          value={trackEditor.title}
                          onChange={(e) => setTrackEditor({ ...trackEditor, title: e.target.value })}
                          placeholder="Track title"
                        />
                        <input
                          type="file"
                          accept="audio/mpeg,.mp3"
                          onChange={(e) => onAudioFileSelected(e.target.files?.[0] ?? null)}
                        />
                      </div>

                      <div className="row">
                        <button onClick={() => setActiveTranscriptTab('pa')}>Punjabi</button>
                        <button onClick={() => setActiveTranscriptTab('hi')}>Hindi</button>
                        <button onClick={() => setActiveTranscriptTab('en')}>English</button>
                      </div>

                      <h5>Transcript: {activeTranscriptTab.toUpperCase()}</h5>
                      <textarea
                        value={trackEditor.transcriptLrc[activeTranscriptTab]}
                        onChange={(e) => setTrackEditor({
                          ...trackEditor,
                          transcriptLrc: { ...trackEditor.transcriptLrc, [activeTranscriptTab]: e.target.value },
                        })}
                        placeholder="Paste LRC for selected language"
                      />
                      <div className="row">
                        <button onClick={() => parseCurrentLrcToJson(activeTranscriptTab)}>Parse LRC</button>
                        <button
                          onClick={() => setTrackEditor({
                            ...trackEditor,
                            baselineTranscriptJson: {
                              ...trackEditor.baselineTranscriptJson,
                              [activeTranscriptTab]: trackEditor.transcriptJson[activeTranscriptTab],
                            },
                          })}
                        >
                          Mark Baseline
                        </button>
                      </div>
                      <textarea
                        value={trackEditor.transcriptJson[activeTranscriptTab]}
                        onChange={(e) => setTrackEditor({
                          ...trackEditor,
                          transcriptJson: { ...trackEditor.transcriptJson, [activeTranscriptTab]: e.target.value },
                        })}
                        placeholder="Transcript JSON for selected language"
                      />

                      {uploadState.loading && (
                        <>
                          <p>Audio upload: {uploadState.audioProgress}%</p>
                          <p>PA upload: {uploadState.transcriptProgress.pa}%</p>
                          <p>HI upload: {uploadState.transcriptProgress.hi}%</p>
                          <p>EN upload: {uploadState.transcriptProgress.en}%</p>
                          <p>{uploadState.message}</p>
                        </>
                      )}
                      {uploadState.error && <p>{uploadState.error}</p>}

                      <div className="row">
                        <button onClick={() => void saveTrack()} disabled={uploadState.loading}>Save Track</button>
                        <button onClick={() => setTrackEditor(null)} disabled={uploadState.loading}>Cancel Track Editor</button>
                      </div>
                    </div>
                  )}
                </>
              )}

              <div className="row">
                <button onClick={() => void saveContentMetadataOnly()} disabled={savingContent || uploadState.loading}>
                  {savingContent ? 'Saving...' : 'Save Content Metadata'}
                </button>
                <button onClick={resetEditorState} disabled={savingContent || uploadState.loading}>Close</button>
              </div>

              {saveMessage && <p>{saveMessage}</p>}
              {saveError && <p>{saveError}</p>}
            </div>
          )}
        </>
      )}
    </div>
  )
}
