import type { RemoteConfig } from '../../lib/remoteConfigTypes'

type RemoteConfigEditorProps = {
  appConfig: RemoteConfig
  onChange: (nextConfig: RemoteConfig) => void
  saving: boolean
  lastPublishedLabel: string
  updatedBy: string
  dirty: boolean
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
        <input type="checkbox" checked={checked} onChange={(event) => onChange(event.target.checked)} />
        <span className="slider" />
      </label>
    </div>
  )
}

export function RemoteConfigEditor({ appConfig, onChange }: RemoteConfigEditorProps) {
  const updateConfig = (changes: Partial<RemoteConfig>) => {
    onChange({
      ...appConfig,
      ...changes,
      versions: { ...appConfig.versions, ...(changes.versions ?? {}) },
      messages: {
        ...appConfig.messages,
        ...(changes.messages ?? {}),
        minorUpdate: {
          ...appConfig.messages.minorUpdate,
          ...(changes.messages?.minorUpdate ?? {}),
        },
        forceUpdate: {
          ...appConfig.messages.forceUpdate,
          ...(changes.messages?.forceUpdate ?? {}),
        },
        maintenance: {
          ...appConfig.messages.maintenance,
          ...(changes.messages?.maintenance ?? {}),
        },
      },
      maintenance: { ...appConfig.maintenance, ...(changes.maintenance ?? {}) },
      storeUrl: { ...appConfig.storeUrl, ...(changes.storeUrl ?? {}) },
    })
  }

  return (
    <div className="remote-config-editor stack">
      <div className="card">
        <h3>Maintenance</h3>
        <ToggleRow
          label="Enable Maintenance Mode"
          description="When active, users are routed to the maintenance screen."
          checked={appConfig.maintenance.enabled}
          onChange={(value) => updateConfig({ maintenance: { enabled: value } })}
        />
      </div>

      <div className="card">
        <h3>Updates</h3>
        <div className="field-grid">
          <div className="field-group">
            <label>Latest Build</label>
            <input
              type="number"
              value={appConfig.versions.latest}
              onChange={(e) => updateConfig({ versions: { latest: Number(e.target.value) } as RemoteConfig['versions'] })}
            />
          </div>
          <div className="field-group">
            <label>Minor Update Build</label>
            <input
              type="number"
              value={appConfig.versions.minorUpdate ?? ''}
              onChange={(e) =>
                updateConfig({
                  versions: {
                    minorUpdate: e.target.value ? Number(e.target.value) : null,
                  } as RemoteConfig['versions'],
                })
              }
            />
          </div>
          <div className="field-group">
            <label>Force Update Build</label>
            <input
              type="number"
              value={appConfig.versions.forceUpdate ?? ''}
              onChange={(e) =>
                updateConfig({
                  versions: {
                    forceUpdate: e.target.value ? Number(e.target.value) : null,
                  } as RemoteConfig['versions'],
                })
              }
            />
          </div>
        </div>
      </div>

      <div className="card">
        <h3>Messages</h3>
        <h4>Force Update</h4>
        <div className="field-grid">
          <div className="field-group full-width">
            <label>Title</label>
            <input
              value={appConfig.messages.forceUpdate.title}
              onChange={(e) =>
                updateConfig({ messages: { forceUpdate: { ...appConfig.messages.forceUpdate, title: e.target.value } } as RemoteConfig['messages'] })
              }
            />
          </div>
          <div className="field-group full-width">
            <label>Body</label>
            <textarea
              value={appConfig.messages.forceUpdate.body}
              onChange={(e) =>
                updateConfig({ messages: { forceUpdate: { ...appConfig.messages.forceUpdate, body: e.target.value } } as RemoteConfig['messages'] })
              }
            />
          </div>
          <div className="field-group full-width">
            <label>Primary Button</label>
            <input
              value={appConfig.messages.forceUpdate.primaryButton}
              onChange={(e) =>
                updateConfig({
                  messages: { forceUpdate: { ...appConfig.messages.forceUpdate, primaryButton: e.target.value } } as RemoteConfig['messages'],
                })
              }
            />
          </div>
        </div>

        <h4 style={{ marginTop: '20px' }}>Minor Update</h4>
        <div className="field-grid">
          <div className="field-group full-width">
            <label>Title</label>
            <input
              value={appConfig.messages.minorUpdate.title}
              onChange={(e) =>
                updateConfig({ messages: { minorUpdate: { ...appConfig.messages.minorUpdate, title: e.target.value } } as RemoteConfig['messages'] })
              }
            />
          </div>
          <div className="field-group full-width">
            <label>Body</label>
            <textarea
              value={appConfig.messages.minorUpdate.body}
              onChange={(e) =>
                updateConfig({ messages: { minorUpdate: { ...appConfig.messages.minorUpdate, body: e.target.value } } as RemoteConfig['messages'] })
              }
            />
          </div>
          <div className="field-group">
            <label>Primary Button</label>
            <input
              value={appConfig.messages.minorUpdate.primaryButton}
              onChange={(e) =>
                updateConfig({
                  messages: { minorUpdate: { ...appConfig.messages.minorUpdate, primaryButton: e.target.value } } as RemoteConfig['messages'],
                })
              }
            />
          </div>
          <div className="field-group">
            <label>Secondary Button</label>
            <input
              value={appConfig.messages.minorUpdate.secondaryButton ?? ''}
              onChange={(e) =>
                updateConfig({
                  messages: { minorUpdate: { ...appConfig.messages.minorUpdate, secondaryButton: e.target.value } } as RemoteConfig['messages'],
                })
              }
            />
          </div>
        </div>

        <h4 style={{ marginTop: '20px' }}>Maintenance</h4>
        <div className="field-grid">
          <div className="field-group full-width">
            <label>Title</label>
            <input
              value={appConfig.messages.maintenance.title}
              onChange={(e) =>
                updateConfig({ messages: { maintenance: { ...appConfig.messages.maintenance, title: e.target.value } } as RemoteConfig['messages'] })
              }
            />
          </div>
          <div className="field-group full-width">
            <label>Body</label>
            <textarea
              value={appConfig.messages.maintenance.body}
              onChange={(e) =>
                updateConfig({ messages: { maintenance: { ...appConfig.messages.maintenance, body: e.target.value } } as RemoteConfig['messages'] })
              }
            />
          </div>
          <div className="field-group full-width">
            <label>Primary Button</label>
            <input
              value={appConfig.messages.maintenance.primaryButton}
              onChange={(e) =>
                updateConfig({
                  messages: { maintenance: { ...appConfig.messages.maintenance, primaryButton: e.target.value } } as RemoteConfig['messages'],
                })
              }
            />
          </div>
        </div>
      </div>

      <div className="card">
        <h3>Store URLs</h3>
        <div className="field-grid">
          <div className="field-group full-width">
            <label>Android URL</label>
            <input value={appConfig.storeUrl.android} onChange={(e) => updateConfig({ storeUrl: { android: e.target.value } as RemoteConfig['storeUrl'] })} />
          </div>
          <div className="field-group full-width">
            <label>iOS URL</label>
            <input value={appConfig.storeUrl.ios} onChange={(e) => updateConfig({ storeUrl: { ios: e.target.value } as RemoteConfig['storeUrl'] })} />
          </div>
        </div>
      </div>
    </div>
  )
}
