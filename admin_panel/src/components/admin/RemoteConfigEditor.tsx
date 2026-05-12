import { useState } from 'react'
import { type RemoteConfig } from '../../lib/remoteConfigTypes'

type RemoteConfigEditorProps = {
  remoteConfig: RemoteConfig
  activeSection: string
  onChange: (nextConfig: RemoteConfig) => void
  saving: boolean
  lastPublishedLabel: string
  updatedBy: string
  dirty: boolean
}

const sectionTitles: Record<string, string> = {
  app_config: 'Remote Control Center',
  version_control: 'Version Control',
  feature_flags: 'Feature Flags',
  maintenance: 'Maintenance',
  languages: 'Language Rollout',
  experimental: 'Experimental Controls',
}

const STATUS_STYLE: Record<string, { label: string; tone: string }> = {
  up_to_date: { label: 'Up to date', tone: 'success' },
  optional_update: { label: 'Optional update', tone: 'accent' },
  force_update: { label: 'Force update required', tone: 'warning' },
}

function formatDateLabel(value: unknown) {
  if (!value) return 'Never published'
  const timestamp = value as any
  if (timestamp?.toDate) {
    return timestamp.toDate().toLocaleString()
  }
  if (timestamp instanceof Date) {
    return timestamp.toLocaleString()
  }
  if (typeof timestamp === 'string') {
    return timestamp
  }
  return 'Recently'
}

function statusFromBuilds(currentBuild: number, latestBuild: number, minimumSupportedBuild: number) {
  if (currentBuild < minimumSupportedBuild) {
    return STATUS_STYLE.force_update
  }
  if (currentBuild < latestBuild) {
    return STATUS_STYLE.optional_update
  }
  return STATUS_STYLE.up_to_date
}

function ToggleRow({
  label,
  description,
  checked,
  onChange,
}: {
  label: string
  description: string
  checked: boolean
  onChange: (value: boolean) => void
}) {
  return (
    <div className="toggle-row">
      <div>
        <label className="field-label">{label}</label>
        <p className="field-description">{description}</p>
      </div>
      <label className="switch">
        <input
          type="checkbox"
          checked={checked}
          onChange={(event) => onChange(event.target.checked)}
        />
        <span className="slider" />
      </label>
    </div>
  )
}

function FlagRow({
  label,
  description,
  checked,
  onChange,
}: {
  label: string
  description: string
  checked: boolean
  onChange: (value: boolean) => void
}) {
  return (
    <div className="flag-row">
      <div>
        <p className="field-label">{label}</p>
        <p className="field-description">{description}</p>
      </div>
      <label className="switch small">
        <input type="checkbox" checked={checked} onChange={(event) => onChange(event.target.checked)} />
        <span className="slider" />
      </label>
    </div>
  )
}

export function RemoteConfigEditor({
  remoteConfig,
  onChange,
  activeSection,
  saving,
  lastPublishedLabel,
  updatedBy,
  dirty,
}: RemoteConfigEditorProps) {
  const focusTitle = sectionTitles[activeSection] ?? sectionTitles.app_config
  const { versionControl, maintenance, featureFlags } = remoteConfig
  const [previewBuild, setPreviewBuild] = useState(versionControl.latestBuild)

  const status = statusFromBuilds(previewBuild, versionControl.latestBuild, versionControl.minimumSupportedBuild)

  const updateVersionControl = (changes: Partial<typeof versionControl>) => {
    onChange({
      ...remoteConfig,
      versionControl: {
        ...versionControl,
        ...changes,
      },
    })
  }

  const updateMaintenance = (changes: Partial<typeof maintenance>) => {
    onChange({
      ...remoteConfig,
      maintenance: {
        ...maintenance,
        ...changes,
      },
    })
  }

  const updateFeatureFlags = (changes: Partial<typeof featureFlags>) => {
    onChange({
      ...remoteConfig,
      featureFlags: {
        ...featureFlags,
        ...changes,
      },
    })
  }

  const updateLanguageFlag = (language: keyof typeof featureFlags.languages, value: boolean) => {
    onChange({
      ...remoteConfig,
      featureFlags: {
        ...featureFlags,
        languages: {
          ...featureFlags.languages,
          [language]: value,
        },
      },
    })
  }

  const statusChipClass = status.tone === 'success' ? 'status-chip success-chip' : status.tone === 'warning' ? 'status-chip warning-chip' : 'status-chip accent-chip'

  return (
    <div className="remote-config-editor stack">
      <div className="section-hero card panel-hero">
        <div>
          <span className="eyebrow">{focusTitle}</span>
          <h2>Bani Sagar remote configuration</h2>
          <p className="field-description" style={{ marginTop: '8px' }}>
            Operational controls for app versions, update logic, maintenance, language rollout, and experimental flags.
          </p>
        </div>
        <div className="row" style={{ gap: '12px', alignItems: 'center', flexWrap: 'wrap' }}>
          <span className="status-chip muted-chip">{remoteConfig.environment}</span>
          <span className={statusChipClass}>{status.label}</span>
          <span className="info-text">{dirty ? 'Unsaved changes' : 'Saved configuration'}</span>
        </div>
      </div>

      <div className="panel-grid">
        <section className="card config-card">
          <div className="section-header">
            <div>
              <h3>Version Control</h3>
              <p className="field-description">Manage builds, update messaging, and store destinations.</p>
            </div>
            <span className="badge accent">Critical</span>
          </div>

          <div className="field-grid">
            <div className="field-group">
              <label>Latest Build Number</label>
              <input
                type="number"
                value={versionControl.latestBuild}
                min={1}
                onChange={(event) => updateVersionControl({ latestBuild: Number(event.target.value) })}
              />
            </div>
            <div className="field-group">
              <label>Minimum Supported Build</label>
              <input
                type="number"
                value={versionControl.minimumSupportedBuild}
                min={1}
                onChange={(event) => updateVersionControl({ minimumSupportedBuild: Number(event.target.value) })}
              />
            </div>
            <div className="field-group">
              <label>Latest Version Name</label>
              <input
                value={versionControl.latestVersionName}
                onChange={(event) => updateVersionControl({ latestVersionName: event.target.value })}
              />
            </div>
            <div className="field-group toggle-group">
              <label>Force Update</label>
              <ToggleRow
                label="Force update"
                description="Block older installations when version support expires."
                checked={versionControl.forceUpdate}
                onChange={(value) => updateVersionControl({ forceUpdate: value })}
              />
            </div>
            <div className="field-group full-width">
              <label>Update Message</label>
              <textarea
                value={versionControl.updateMessage}
                onChange={(event) => updateVersionControl({ updateMessage: event.target.value })}
              />
            </div>
            <div className="field-group">
              <label>Android Store URL</label>
              <input
                value={versionControl.androidStoreUrl}
                onChange={(event) => updateVersionControl({ androidStoreUrl: event.target.value })}
              />
            </div>
            <div className="field-group">
              <label>iOS Store URL</label>
              <input
                value={versionControl.iosStoreUrl}
                onChange={(event) => updateVersionControl({ iosStoreUrl: event.target.value })}
              />
            </div>
          </div>

          <div className="section-divider" />

          <div className="field-grid preview-grid">
            <div className="field-group">
              <label>Current device build</label>
              <input
                type="number"
                min={1}
                value={previewBuild}
                onChange={(event) => setPreviewBuild(Number(event.target.value))}
              />
            </div>
            <div className="field-group">
              <label>Status preview</label>
              <div className={`status-chip ${status.tone === 'success' ? 'success-chip' : status.tone === 'warning' ? 'warning-chip' : 'accent-chip'}`}>
                {status.label}
              </div>
            </div>
          </div>
        </section>

        <section className="card config-card">
          <div className="section-header">
            <div>
              <h3>Maintenance Mode</h3>
              <p className="field-description">Enable scheduled downtime with a calm, informative message.</p>
            </div>
            <span className="badge warning">Safeguard</span>
          </div>

          <ToggleRow
            label="Maintenance mode"
            description="When active, users are routed to the maintenance screen with a gentle message."
            checked={maintenance.isUnderMaintenance}
            onChange={(value) => updateMaintenance({ isUnderMaintenance: value })}
          />

          <div className="field-group full-width" style={{ marginTop: '18px' }}>
            <label>Maintenance message</label>
            <textarea
              value={maintenance.maintenanceMessage}
              onChange={(event) => updateMaintenance({ maintenanceMessage: event.target.value })}
            />
          </div>
        </section>

        <section className="card config-card">
          <div className="section-header">
            <div>
              <h3>Feature Flags</h3>
              <p className="field-description">Roll out language and experimental experiences safely.</p>
            </div>
            <span className="badge soft">Flexible</span>
          </div>

          <div className="flag-grid">
            <FlagRow
              label="Punjabi language"
              description="Control whether Punjabi language access is enabled in the app."
              checked={featureFlags.languages.punjabi}
              onChange={(value) => updateLanguageFlag('punjabi', value)}
            />
            <FlagRow
              label="English language"
              description="Enable English rollout for a wider set of users."
              checked={featureFlags.languages.english}
              onChange={(value) => updateLanguageFlag('english', value)}
            />
            <FlagRow
              label="Hindi language"
              description="Switch on Hindi rollout during phased release."
              checked={featureFlags.languages.hindi}
              onChange={(value) => updateLanguageFlag('hindi', value)}
            />
            <FlagRow
              label="Focus reading mode"
              description="Enable an immersive reading experience for active sessions."
              checked={featureFlags.focus_reading_mode}
              onChange={(value) => updateFeatureFlags({ focus_reading_mode: value })}
            />
            <FlagRow
              label="New player UI"
              description="Toggle the updated player experience for testing."
              checked={featureFlags.new_player_ui}
              onChange={(value) => updateFeatureFlags({ new_player_ui: value })}
            />
            <FlagRow
              label="Experimental home"
              description="Activate a preview home screen flow for internal review."
              checked={featureFlags.experimental_home}
              onChange={(value) => updateFeatureFlags({ experimental_home: value })}
            />
          </div>
        </section>

        <section className="card preview-card">
          <div className="section-header">
            <div>
              <h3>Preview & workflow</h3>
              <p className="field-description">Simulate how the app will present updates, maintenance, and release status.</p>
            </div>
          </div>

          <div className="preview-surface">
            {maintenance.isUnderMaintenance ? (
              <div className="preview-block">
                <span className="preview-title">Maintenance mode active</span>
                <p>{maintenance.maintenanceMessage}</p>
                <div className="badge warning">Maintenance</div>
              </div>
            ) : versionControl.forceUpdate && previewBuild < versionControl.minimumSupportedBuild ? (
              <div className="preview-block">
                <span className="preview-title">Force update required</span>
                <p>{versionControl.updateMessage}</p>
                <button className="outline">Update now</button>
              </div>
            ) : previewBuild < versionControl.latestBuild ? (
              <div className="preview-block">
                <span className="preview-title">Optional update</span>
                <p>{versionControl.updateMessage}</p>
                <div className="row" style={{ gap: '10px', flexWrap: 'wrap' }}>
                  <button className="secondary">Continue</button>
                  <button>Update now</button>
                </div>
              </div>
            ) : (
              <div className="preview-block">
                <span className="preview-title">App is up to date</span>
                <p>Current build is within the supported range and no update flow is displayed.</p>
                <div className="status-chip success-chip">Stable</div>
              </div>
            )}
          </div>

          <div className="field-grid" style={{ marginTop: '16px' }}>
            <div>
              <p className="field-label">Last published</p>
              <p className="info-text">{lastPublishedLabel}</p>
            </div>
            <div>
              <p className="field-label">Updated by</p>
              <p className="info-text">{updatedBy || 'Unknown'}</p>
            </div>
          </div>
        </section>
      </div>
    </div>
  )
}
