import { contentDisplayTitle, ContentItem } from '../../lib/contentTypes'

type PrayerCardProps = {
  item: ContentItem
  onEdit: () => void
  onDelete: () => void
  dragHandleProps?: any
}

export function PrayerCard({ item, onEdit, onDelete, dragHandleProps }: PrayerCardProps) {
  const isPrayer = item.type === 'prayer'
  const activeTrackId = isPrayer ? item.active_track : null
  const activeTrack = isPrayer ? item.tracks[activeTrackId || ''] : null
  const trackCount = isPrayer ? Object.keys(item.tracks).length : 0

  return (
    <div className="content-item fade-in">
      <div className="row spread">
        <div className="row" style={{ gap: '12px', flex: 1 }}>
          <div 
            {...dragHandleProps} 
            style={{ 
              cursor: 'grab', 
              padding: '8px', 
              display: 'flex', 
              alignItems: 'center',
              color: '#ccc' 
            }}
            title="Drag to reorder"
          >
            <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
              <path d="M7 2a2 2 0 1 0 .001 4.001A2 2 0 0 0 7 2zm0 6a2 2 0 1 0 .001 4.001A2 2 0 0 0 7 8zm0 6a2 2 0 1 0 .001 4.001A2 2 0 0 0 7 14zm6-12a2 2 0 1 0 .001 4.001A2 2 0 0 0 13 2zm0 6a2 2 0 1 0 .001 4.001A2 2 0 0 0 13 8zm0 6a2 2 0 1 0 .001 4.001A2 2 0 0 0 13 14z" />
            </svg>
          </div>

          <div className="stack" style={{ gap: '10px', flex: 1 }}>
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
          </div>
        </div>
        
        <div className="row" style={{ gap: '8px' }}>
          <button className="outline" onClick={onEdit}>Edit</button>
          <button className="outline danger" onClick={onDelete} style={{ color: 'red' }}>Delete</button>
        </div>
      </div>
    </div>
  )
}
