import type { MenuSettings } from '../../lib/remoteConfigTypes'

type MenuSettingsEditorProps = {
  settings: MenuSettings
  onChange: (nextSettings: MenuSettings) => void
}

function ToggleRow({
  label,
  checked,
  onChange,
}: {
  label: string
  checked: boolean
  onChange: (value: boolean) => void
}) {
  return (
    <div className="toggle-row">
      <label className="field-label">{label}</label>
      <label className="switch">
        <input type="checkbox" checked={checked} onChange={(event) => onChange(event.target.checked)} />
        <span className="slider" />
      </label>
    </div>
  )
}

export function MenuSettingsEditor({ settings, onChange }: MenuSettingsEditorProps) {
  const toggleItem = (id: string, enabled: boolean) => {
    const currentItems = settings.enabledItems
    const nextItems = enabled
      ? [...currentItems, id]
      : currentItems.filter((item) => item !== id)

    onChange({
      ...settings,
      enabledItems: nextItems,
    })
  }

  const items = [
    { id: 'theme', label: 'Theme', section: 'Appearance' },
    { id: 'language', label: 'Language', section: 'Appearance' },
    { id: 'typography', label: 'Typography', section: 'Appearance' },
    { id: 'notifications', label: 'Notifications', section: 'Notifications' },
    { id: 'clear_cache', label: 'Clear Cache', section: 'Storage' },
    { id: 'keep_awake', label: 'Keep Awake', section: 'Experience' },
    { id: 'share', label: 'Share App', section: 'Support' },
    { id: 'support_dev', label: 'Support Development', section: 'Support' },
    { id: 'feedback', label: 'Feedback', section: 'Support' },
    { id: 'faq', label: 'FAQ', section: 'Support' },
    { id: 'privacy_policy', label: 'Privacy Policy', section: 'Support' },
  ]

  const sections = Array.from(new Set(items.map((i) => i.section)))

  return (
    <div className="stack">
      {sections.map((section) => (
        <div key={section} className="card">
          <h3>{section}</h3>
          <div className="stack">
            {items
              .filter((i) => i.section === section)
              .map((item) => (
                <ToggleRow
                  key={item.id}
                  label={item.label}
                  checked={settings.enabledItems.includes(item.id)}
                  onChange={(checked) => toggleItem(item.id, checked)}
                />
              ))}
          </div>
        </div>
      ))}
    </div>
  )
}
