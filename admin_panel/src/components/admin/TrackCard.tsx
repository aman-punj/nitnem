import { PrayerTrack } from '../../lib/contentTypes'

type TrackCardProps = {
  track: PrayerTrack
  isActive: boolean
  onEdit: () => void
  onSetActive: () => void
}

export function TrackCard({ track, isActive, onEdit, onSetActive }: TrackCardProps) {
  return (
    <div className="content-item">
      <div className="row spread">
        <div className="stack" style={{ gap: '8px' }}>
          <div className="row">
            <strong>{track.title}</strong>
            {isActive && <span className="badge active">Active</span>}
            {!isActive && <span className="badge inactive">Inactive</span>}
          </div>
          <div className="info-text">
            ID: {track.id}
          </div>
          <div className="row" style={{ gap: '8px' }}>
            <span className="badge track">Audio v{track.audio?.version ?? 0}</span>
            <span className="badge type">PA v{track.transcripts.pa?.version ?? 0}</span>
            <span className="badge type">HI v{track.transcripts.hi?.version ?? 0}</span>
            <span className="badge type">EN v{track.transcripts.en?.version ?? 0}</span>
          </div>
        </div>
        <div className="row">
          {!isActive && (
            <button className="secondary" onClick={onSetActive}>
              Set Active
            </button>
          )}
          <button className="outline" onClick={onEdit}>
            Edit Track
          </button>
        </div>
      </div>
    </div>
  )
}
