import { useEffect, useState } from 'react'
import { fetchRecentAnnouncements, sendBroadcast } from '../../lib/notificationsService'
import { Announcement, NotificationSettings } from '../../lib/notificationsTypes'

interface Props {
  settings: NotificationSettings
  onChange: (next: NotificationSettings) => void
  saving: boolean
  dirty: boolean
  lastPublishedLabel: string
}

export function NotificationsEditor({ settings, onChange, saving, dirty, lastPublishedLabel }: Props) {
  const [broadcastTitle, setBroadcastTitle] = useState('')
  const [broadcastBody, setBroadcastBody] = useState('')
  const [sending, setSending] = useState(false)
  const [sendResult, setSendResult] = useState<{ ok: boolean; msg: string } | null>(null)
  const [announcements, setAnnouncements] = useState<Announcement[]>([])
  const [loadingHistory, setLoadingHistory] = useState(true)

  useEffect(() => {
    void loadHistory()
  }, [])

  async function loadHistory() {
    setLoadingHistory(true)
    try {
      setAnnouncements(await fetchRecentAnnouncements())
    } catch {
      // non-critical
    } finally {
      setLoadingHistory(false)
    }
  }

  async function handleSendBroadcast() {
    if (!broadcastTitle.trim() || !broadcastBody.trim()) return
    setSending(true)
    setSendResult(null)
    try {
      await sendBroadcast(broadcastTitle.trim(), broadcastBody.trim())
      setSendResult({ ok: true, msg: 'Queued successfully. Users will see it on next app open.' })
      setBroadcastTitle('')
      setBroadcastBody('')
      void loadHistory()
    } catch (e) {
      setSendResult({ ok: false, msg: e instanceof Error ? e.message : 'Failed to queue broadcast.' })
    } finally {
      setSending(false)
    }
  }

  function formatTs(value: unknown): string {
    if (!value) return '—'
    const ts = value as any
    if (ts?.toDate) return ts.toDate().toLocaleString()
    if (ts instanceof Date) return ts.toLocaleString()
    return String(value)
  }

  return (
    <div className="stack">
      {/* Prayer Notification Times */}
      <div className="card">
        <div className="row spread" style={{ marginBottom: '16px' }}>
          <div>
            <h3 style={{ margin: 0 }}>Prayer Notification Times</h3>
            <p className="info-text" style={{ marginTop: '4px' }}>
              These are the default times sent to users' devices. Users can override locally.
            </p>
          </div>
          {dirty && <span className="badge accent">Unsaved</span>}
        </div>

        <div className="field-grid" style={{ gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
          {/* Morning */}
          <div className="stack" style={{ gap: '12px' }}>
            <h4 style={{ margin: 0, color: 'var(--accent)' }}>🌅 Morning Nitnem</h4>
            <div className="field-group">
              <label>Time</label>
              <input
                type="time"
                value={settings.morning_time}
                onChange={e => onChange({ ...settings, morning_time: e.target.value })}
              />
            </div>
            <div className="field-group">
              <label>Notification Message</label>
              <input
                type="text"
                value={settings.morning_message}
                onChange={e => onChange({ ...settings, morning_message: e.target.value })}
                placeholder="e.g. Time for your morning Nitnem"
              />
            </div>
          </div>

          {/* Evening */}
          <div className="stack" style={{ gap: '12px' }}>
            <h4 style={{ margin: 0, color: 'var(--accent)' }}>🌙 Evening Nitnem</h4>
            <div className="field-group">
              <label>Time</label>
              <input
                type="time"
                value={settings.evening_time}
                onChange={e => onChange({ ...settings, evening_time: e.target.value })}
              />
            </div>
            <div className="field-group">
              <label>Notification Message</label>
              <input
                type="text"
                value={settings.evening_message}
                onChange={e => onChange({ ...settings, evening_message: e.target.value })}
                placeholder="e.g. Time for your evening Nitnem"
              />
            </div>
          </div>
        </div>

        <p className="info-text" style={{ marginTop: '16px' }}>
          Last saved: {lastPublishedLabel} &nbsp;·&nbsp;
          {saving ? 'Saving…' : dirty ? 'Click "Publish Changes" in the toolbar to save.' : 'Up to date'}
        </p>
      </div>

      {/* Broadcast (Kumnama Topic) */}
      <div className="card">
        <h3 style={{ margin: '0 0 4px' }}>Send Hukamnama Broadcast</h3>
        <p className="info-text" style={{ marginBottom: '16px' }}>
          Sends a push notification to all users subscribed to the <strong>kumnama</strong> topic —
          including devices where the app is closed.
        </p>

        <div className="stack" style={{ gap: '12px' }}>
          <div className="field-group">
            <label>Title</label>
            <input
              type="text"
              value={broadcastTitle}
              onChange={e => setBroadcastTitle(e.target.value)}
              placeholder="e.g. Hukamnama – Ang 123"
              maxLength={80}
            />
          </div>
          <div className="field-group">
            <label>Message</label>
            <textarea
              rows={3}
              value={broadcastBody}
              onChange={e => setBroadcastBody(e.target.value)}
              placeholder="Enter the Hukamnama text or message…"
              maxLength={300}
              style={{ resize: 'vertical' }}
            />
            <span className="info-text">{broadcastBody.length}/300</span>
          </div>

          {sendResult && (
            <div
              className="card"
              style={{
                padding: '10px 14px',
                background: sendResult.ok ? '#f0faf0' : '#fff0f0',
                borderColor: sendResult.ok ? '#2e7d32' : 'var(--error)',
                color: sendResult.ok ? '#2e7d32' : 'var(--error)',
              }}
            >
              {sendResult.msg}
            </div>
          )}

          <div>
            <button
              onClick={() => void handleSendBroadcast()}
              disabled={sending || !broadcastTitle.trim() || !broadcastBody.trim()}
            >
              {sending ? 'Sending…' : 'Send Broadcast'}
            </button>
          </div>
        </div>
      </div>

      {/* Broadcast History */}
      <div className="card">
        <div className="row spread" style={{ marginBottom: '12px' }}>
          <h3 style={{ margin: 0 }}>Broadcast History</h3>
          <button className="secondary" onClick={() => void loadHistory()} disabled={loadingHistory}>
            {loadingHistory ? 'Loading…' : 'Refresh'}
          </button>
        </div>

        {announcements.length === 0 && !loadingHistory && (
          <div className="empty-state">No broadcasts sent yet.</div>
        )}

        {announcements.map(a => (
          <div
            key={a.id}
            style={{
              padding: '12px 0',
              borderBottom: '1px solid var(--border)',
              display: 'flex',
              gap: '12px',
              alignItems: 'flex-start',
            }}
          >
            <span
              style={{
                fontSize: '11px',
                fontWeight: 600,
                padding: '2px 8px',
                borderRadius: '99px',
                background: a.status === 'sent' ? '#e8f5e9' : a.status === 'failed' ? '#ffebee' : '#fff8e1',
                color: a.status === 'sent' ? '#2e7d32' : a.status === 'failed' ? '#c62828' : '#f57f17',
                whiteSpace: 'nowrap',
                marginTop: '2px',
              }}
            >
              {a.status}
            </span>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontWeight: 600, marginBottom: '2px' }}>{a.title}</div>
              <div className="info-text" style={{ marginBottom: '4px' }}>{a.body}</div>
              <div className="info-text">{formatTs(a.createdAt)} · by {a.createdBy}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
