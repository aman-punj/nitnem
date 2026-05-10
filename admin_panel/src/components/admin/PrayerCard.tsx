import { contentDisplayTitle, ContentItem } from '../../lib/contentTypes'

type PrayerCardProps = {
  item: ContentItem
  onEdit: () => void
}

export function PrayerCard({ item, onEdit }: PrayerCardProps) {
  const isPrayer = item.type === 'prayer'
  const activeTrackId = isPrayer ? item.active_track : null
  const activeTrack = isPrayer ? item.tracks[activeTrackId || ''] : null
  const trackCount = isPrayer ? Object.keys(item.tracks).length : 0

  return (
    <div className="content-item fade-in">
      <div className="row spread">
        <div className="stack" style={{ gap: '10px' }}>
          <div>
            <h3 style={{ margin: 0 }}>{contentDisplayTitle(item)}</h3>
            <div className="row" style={{ marginTop: '4px', gap: '8px' }}>
              <span className={`badge ${item.enabled ? 'active' : 'inactive'}`}>
                {item.enabled ? 'Enabled' : 'Disabled'}
              </span>
              <span className="badge type">{item.type}</span>
              {isPrayer && <span className="badge track">{trackCount} Tracks</span>}
            </div>
          </div>
          
          <div className="info-text">
            <p>Punjabi: {item.titles.pa}</p>
            <p>Hindi: {item.titles.hi}</p>
          </div>

          {isPrayer && activeTrack && (
            <div className="info-text" style={{ padding: '8px', background: '#f9f9f9', borderRadius: '8px' }}>
              <strong>Active Track:</strong> {activeTrack.title}
              <div className="row" style={{ marginTop: '4px', gap: '8px', fontSize: '11px' }}>
                <span>Audio v{activeTrack.audio?.version ?? 0}</span>
                <span>PA v{activeTrack.transcripts.pa?.version ?? 0}</span>
                <span>HI v{activeTrack.transcripts.hi?.version ?? 0}</span>
                <span>EN v{activeTrack.transcripts.en?.version ?? 0}</span>
              </div>
            </div>
          )}

          {!isPrayer && (
            <div className="info-text">
              <strong>URL:</strong> {item.youtube_url}
            </div>
          )}
        </div>
        
        <button onClick={onEdit}>Edit</button>
      </div>
    </div>
  )
}
