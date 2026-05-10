import { useEffect, useMemo, useState } from 'react'

import { parseLrc } from '../lib/transcript'
import {
  initAuthPersistence,
  isAllowedAdminEmail,
  onAdminAuthChange,
  signInAdminWithGoogle,
  signOutAdmin,
} from '../lib/firebase'
import { fetchContentList, upsertContentItem } from '../lib/contentService'
import { uploadAudioToCloudinary, uploadTranscriptJsonToCloudinary } from '../lib/cloudinary'
import type { ContentItem, ContentType, PrayerContentData, PrayerTrack, YoutubeLiveContentData } from '../lib/contentTypes'

type AuthStatus = 'checking' | 'signed_out' | 'signed_in' | 'error'
type UploadState = {
  audioProgress: number
  transcriptProgress: number
  loading: boolean
  message: string
  error: string
}

function defaultUploadState(): UploadState {
  return {
    audioProgress: 0,
    transcriptProgress: 0,
    loading: false,
    message: '',
    error: '',
  }
}

export function AdminApp() {
  const [authStatus, setAuthStatus] = useState<AuthStatus>('checking')
  const [authUserEmail, setAuthUserEmail] = useState('')
  const [authMessage, setAuthMessage] = useState('')
  const [authLoading, setAuthLoading] = useState(false)

  const [contentItems, setContentItems] = useState<ContentItem[]>([])
  const [contentLoading, setContentLoading] = useState(false)
  const [contentError, setContentError] = useState('')
  const [search, setSearch] = useState('')

  const [editorMode, setEditorMode] = useState<'add' | 'edit' | null>(null)
  const [editingId, setEditingId] = useState('')
  const [contentType, setContentType] = useState<ContentType>('prayer')
  const [title, setTitle] = useState('')
  const [enabled, setEnabled] = useState(true)

  const [activeTrack, setActiveTrack] = useState('track_1')
  const [trackId, setTrackId] = useState('track_1')
  const [audioFile, setAudioFile] = useState<File | null>(null)
  const [transcriptLrc, setTranscriptLrc] = useState('')
  const [transcriptJson, setTranscriptJson] = useState('')
  const [initialTranscriptJson, setInitialTranscriptJson] = useState('')

  const [youtubeSubtitle, setYoutubeSubtitle] = useState('')
  const [youtubeUrl, setYoutubeUrl] = useState('')
  const [youtubeThumbnail, setYoutubeThumbnail] = useState('')

  const [selectedExisting, setSelectedExisting] = useState<ContentItem | null>(null)
  const [saveLoading, setSaveLoading] = useState(false)
  const [saveMessage, setSaveMessage] = useState('')
  const [saveError, setSaveError] = useState('')
  const [uploadState, setUploadState] = useState<UploadState>(defaultUploadState())

  const isAuthed = authStatus === 'signed_in'

  const filteredItems = useMemo(() => {
    const query = search.trim().toLowerCase()
    if (!query) return contentItems
    return contentItems.filter((item) => item.title.toLowerCase().includes(query) || item.id.toLowerCase().includes(query))
  }, [contentItems, search])

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

    return () => {
      unsub()
    }
  }, [])

  useEffect(() => {
    if (!isAuthed) return
    void loadContent()
  }, [isAuthed])

  async function loadContent(): Promise<void> {
    setContentLoading(true)
    setContentError('')
    try {
      const list = await fetchContentList()
      setContentItems(list)
    } catch (error) {
      setContentError(error instanceof Error ? error.message : 'Failed to load content list.')
    } finally {
      setContentLoading(false)
    }
  }

  function resetEditor(): void {
    setEditorMode(null)
    setEditingId('')
    setContentType('prayer')
    setTitle('')
    setEnabled(true)
    setActiveTrack('track_1')
    setTrackId('track_1')
    setAudioFile(null)
    setTranscriptLrc('')
    setTranscriptJson('')
    setInitialTranscriptJson('')
    setYoutubeSubtitle('')
    setYoutubeUrl('')
    setYoutubeThumbnail('')
    setSelectedExisting(null)
    setSaveMessage('')
    setSaveError('')
    setUploadState(defaultUploadState())
  }

  function startAdd(): void {
    resetEditor()
    setEditorMode('add')
  }

  function startEdit(item: ContentItem): void {
    resetEditor()
    setEditorMode('edit')
    setSelectedExisting(item)
    setEditingId(item.id)
    setTitle(item.title)
    setEnabled(item.enabled)
    setContentType(item.type)

    if (item.type === 'prayer') {
      setActiveTrack(item.active_track)
      setTrackId(item.active_track)
    } else {
      setYoutubeSubtitle(item.subtitle ?? '')
      setYoutubeUrl(item.youtube_url)
      setYoutubeThumbnail(item.thumbnail ?? '')
    }
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
      resetEditor()
    } catch (error) {
      setAuthStatus('error')
      setAuthMessage(error instanceof Error ? error.message : 'Logout failed.')
    } finally {
      setAuthLoading(false)
    }
  }

  function parseLrcToJson(): void {
    const parsed = parseLrc(transcriptLrc)
    const text = JSON.stringify({ segments: parsed }, null, 2)
    setTranscriptJson(text)
  }

  async function saveContent(): Promise<void> {
    setSaveError('')
    setSaveMessage('')

    if (!editingId.trim()) {
      setSaveError('Content id is required.')
      return
    }

    if (!title.trim()) {
      setSaveError('Title is required.')
      return
    }

    setSaveLoading(true)

    try {
      if (contentType === 'youtube_live') {
        if (!youtubeUrl.trim()) {
          throw new Error('YouTube URL is required for youtube_live content.')
        }

        const payload: YoutubeLiveContentData = {
          id: editingId.trim(),
          type: 'youtube_live',
          title: title.trim(),
          subtitle: youtubeSubtitle.trim(),
          youtube_url: youtubeUrl.trim(),
          thumbnail: youtubeThumbnail.trim(),
          enabled,
        }

        await upsertContentItem(payload)
        setSaveMessage('youtube_live content saved.')
      } else {
        const existingPrayer = selectedExisting?.type === 'prayer' ? selectedExisting : null
        const tracks = { ...(existingPrayer?.tracks ?? {}) }
        const existingTrack: PrayerTrack = { ...(tracks[trackId] ?? {}) }

        const shouldUploadAudio = audioFile !== null
        const shouldUploadTranscript = transcriptJson.trim().length > 0 && transcriptJson.trim() !== initialTranscriptJson.trim()

        let nextAudioUrl = existingTrack.audio_url
        let nextPaUrl = existingTrack.pa_url

        setUploadState({
          audioProgress: 0,
          transcriptProgress: 0,
          loading: shouldUploadAudio || shouldUploadTranscript,
          message: shouldUploadAudio || shouldUploadTranscript ? 'Uploading assets before Firestore update...' : '',
          error: '',
        })

        if (shouldUploadAudio && audioFile) {
          const uploaded = await uploadAudioToCloudinary(audioFile, (percent) => {
            setUploadState((prev) => ({ ...prev, audioProgress: percent }))
          })
          nextAudioUrl = uploaded.secureUrl
        }

        if (shouldUploadTranscript) {
          const uploaded = await uploadTranscriptJsonToCloudinary(
            transcriptJson,
            `${editingId}_${trackId}_pa.json`,
            (percent) => {
              setUploadState((prev) => ({ ...prev, transcriptProgress: percent }))
            },
          )
          nextPaUrl = uploaded.secureUrl
        }

        const previousAudioVersion = existingTrack.audio_version ?? 1
        const previousLyricsVersion = existingTrack.lyrics_version ?? 1

        tracks[trackId] = {
          ...existingTrack,
          audio_url: nextAudioUrl,
          pa_url: nextPaUrl,
          audio_version: shouldUploadAudio ? previousAudioVersion + 1 : previousAudioVersion,
          lyrics_version: shouldUploadTranscript ? previousLyricsVersion + 1 : previousLyricsVersion,
        }

        const payload: PrayerContentData = {
          id: editingId.trim(),
          type: 'prayer',
          title: title.trim(),
          enabled,
          active_track: activeTrack.trim() || trackId.trim(),
          tracks,
        }

        await upsertContentItem(payload)
        setUploadState((prev) => ({ ...prev, loading: false, message: 'Uploads and Firestore update completed.' }))
        setSaveMessage('Prayer content saved.')
      }

      await loadContent()
    } catch (error) {
      setUploadState((prev) => ({ ...prev, loading: false, error: error instanceof Error ? error.message : 'Upload failed.' }))
      setSaveError(error instanceof Error ? error.message : 'Failed to save content.')
    } finally {
      setSaveLoading(false)
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

      {!isAuthed && <div className="card"><p>Sign in with an allowlisted admin email to access the dashboard.</p></div>}

      {isAuthed && (
        <>
          <div className="card">
            <div className="row spread">
              <h3>Content</h3>
              <div className="row">
                <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search content" />
                <button onClick={startAdd}>Add Content</button>
                <button onClick={() => void loadContent()} disabled={contentLoading}>Reload</button>
              </div>
            </div>

            {contentLoading && <p>Loading content...</p>}
            {contentError && <p>{contentError}</p>}
            {!contentLoading && filteredItems.length === 0 && <p>No content found. Use Add Content to create one.</p>}

            {filteredItems.map((item) => {
              const activeTrackInfo = item.type === 'prayer' ? item.tracks[item.active_track] : null
              return (
                <div key={item.id} className="content-item">
                  <div className="row spread">
                    <div>
                      <strong>{item.title}</strong>
                      <p>ID: {item.id}</p>
                      <p>Type: {item.type}</p>
                      <p>Enabled: {item.enabled ? 'Yes' : 'No'}</p>
                      <p>Active Track: {item.type === 'prayer' ? item.active_track : '-'}</p>
                      <p>
                        Versions: {item.type === 'prayer'
                          ? `audio ${activeTrackInfo?.audio_version ?? '-'}, lyrics ${activeTrackInfo?.lyrics_version ?? '-'}`
                          : '-'}
                      </p>
                    </div>
                    <button onClick={() => startEdit(item)}>Edit</button>
                  </div>
                </div>
              )
            })}
          </div>

          {editorMode && (
            <div className="card">
              <h3>{editorMode === 'add' ? 'Add Content' : `Edit Content: ${editingId}`}</h3>

              <div className="row">
                <input value={editingId} onChange={(e) => setEditingId(e.target.value)} placeholder="content id" disabled={editorMode === 'edit'} />
                <input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="title" />
                <select value={contentType} onChange={(e) => setContentType(e.target.value as ContentType)} disabled={editorMode === 'edit'}>
                  <option value="prayer">prayer</option>
                  <option value="youtube_live">youtube_live</option>
                </select>
                <label>
                  <input type="checkbox" checked={enabled} onChange={(e) => setEnabled(e.target.checked)} /> Enabled
                </label>
              </div>

              {contentType === 'prayer' && (
                <>
                  <div className="row">
                    <input value={trackId} onChange={(e) => setTrackId(e.target.value)} placeholder="track id (e.g. track_1)" />
                    <input value={activeTrack} onChange={(e) => setActiveTrack(e.target.value)} placeholder="active track" />
                    <input type="file" accept="audio/mpeg,.mp3" onChange={(e) => setAudioFile(e.target.files?.[0] ?? null)} />
                  </div>

                  <h4>Punjabi Transcript</h4>
                  <textarea value={transcriptLrc} onChange={(e) => setTranscriptLrc(e.target.value)} placeholder="Paste LRC to parse transcript" />
                  <div className="row">
                    <button onClick={parseLrcToJson}>Parse LRC to JSON</button>
                    <button onClick={() => setInitialTranscriptJson(transcriptJson)}>Mark Transcript as Baseline</button>
                  </div>
                  <textarea value={transcriptJson} onChange={(e) => setTranscriptJson(e.target.value)} placeholder="Transcript JSON to upload" />

                  {uploadState.loading && (
                    <>
                      <p>Audio upload progress: {uploadState.audioProgress}%</p>
                      <p>Transcript upload progress: {uploadState.transcriptProgress}%</p>
                      <p>{uploadState.message}</p>
                    </>
                  )}
                  {uploadState.error && <p>{uploadState.error}</p>}
                </>
              )}

              {contentType === 'youtube_live' && (
                <div className="row">
                  <input value={youtubeSubtitle} onChange={(e) => setYoutubeSubtitle(e.target.value)} placeholder="subtitle" />
                  <input value={youtubeUrl} onChange={(e) => setYoutubeUrl(e.target.value)} placeholder="youtube_url" />
                  <input value={youtubeThumbnail} onChange={(e) => setYoutubeThumbnail(e.target.value)} placeholder="thumbnail (optional)" />
                </div>
              )}

              <div className="row">
                <button onClick={() => void saveContent()} disabled={saveLoading}>{saveLoading ? 'Saving...' : 'Save Content'}</button>
                <button onClick={resetEditor}>Close Editor</button>
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
