import { useState } from 'react'
import { Quote, QuotesConfig } from '../../lib/quotesService'

interface Props {
  config: QuotesConfig
  onChange: (next: QuotesConfig) => void
  saving: boolean
  dirty: boolean
  lastPublishedLabel: string
}

function blankQuote(): Quote {
  return { text: '', author: '' }
}

export function QuotesEditor({ config, onChange, saving, dirty, lastPublishedLabel }: Props) {
  const [editingIndex, setEditingIndex] = useState<number | null>(null)
  const [draft, setDraft] = useState<Quote>(blankQuote())
  const [isAdding, setIsAdding] = useState(false)

  function startAdd() {
    setDraft(blankQuote())
    setIsAdding(true)
    setEditingIndex(null)
  }

  function startEdit(index: number) {
    setDraft({ ...config.quotes[index] })
    setEditingIndex(index)
    setIsAdding(false)
  }

  function cancelEdit() {
    setEditingIndex(null)
    setIsAdding(false)
    setDraft(blankQuote())
  }

  function commitEdit() {
    if (!draft.text.trim()) return
    const updated = [...config.quotes]
    if (isAdding) {
      updated.push(draft)
    } else if (editingIndex !== null) {
      updated[editingIndex] = draft
    }
    onChange({ ...config, quotes: updated })
    cancelEdit()
  }

  function deleteQuote(index: number) {
    if (!confirm('Delete this quote?')) return
    const updated = config.quotes.filter((_, i) => i !== index)
    onChange({ ...config, quotes: updated })
    if (editingIndex === index) cancelEdit()
  }

  function moveUp(index: number) {
    if (index === 0) return
    const updated = [...config.quotes]
    ;[updated[index - 1], updated[index]] = [updated[index], updated[index - 1]]
    onChange({ ...config, quotes: updated })
  }

  function moveDown(index: number) {
    if (index === config.quotes.length - 1) return
    const updated = [...config.quotes]
    ;[updated[index], updated[index + 1]] = [updated[index + 1], updated[index]]
    onChange({ ...config, quotes: updated })
  }

  return (
    <div className="stack">
      <div className="card">
        <div className="row spread" style={{ marginBottom: '16px' }}>
          <div>
            <h3 style={{ margin: 0 }}>Sacred Quotes</h3>
            <p className="info-text" style={{ marginTop: '4px' }}>
              Quotes shown at the bottom of the Settings screen. One is picked randomly on each app start.
              The app also has 4 built-in fallback quotes shown when offline.
            </p>
          </div>
          {dirty && <span className="badge accent">Unsaved</span>}
        </div>

        {/* Quote list */}
        {config.quotes.length === 0 && !isAdding && (
          <div className="empty-state" style={{ marginBottom: '16px' }}>
            No quotes yet. Add one below — the app will use its built-in fallbacks until you publish.
          </div>
        )}

        <div className="stack" style={{ gap: '10px', marginBottom: '16px' }}>
          {config.quotes.map((q, i) => (
            <div
              key={i}
              className="card"
              style={{
                padding: '12px 14px',
                background: editingIndex === i ? 'var(--surface-elevated)' : undefined,
                borderColor: editingIndex === i ? 'var(--accent)' : undefined,
              }}
            >
              {editingIndex === i ? (
                <div className="stack" style={{ gap: '10px' }}>
                  <div className="field-group">
                    <label>Quote text</label>
                    <textarea
                      rows={3}
                      value={draft.text}
                      onChange={(e) => setDraft({ ...draft, text: e.target.value })}
                      placeholder="Enter the quote…"
                      style={{ resize: 'vertical' }}
                      autoFocus
                    />
                  </div>
                  <div className="field-group">
                    <label>Author (optional)</label>
                    <input
                      type="text"
                      value={draft.author ?? ''}
                      onChange={(e) => setDraft({ ...draft, author: e.target.value })}
                      placeholder="e.g. Sri Guru Granth Sahib Ji"
                    />
                  </div>
                  <div className="row" style={{ gap: '8px' }}>
                    <button onClick={commitEdit} disabled={!draft.text.trim()}>Save</button>
                    <button className="secondary" onClick={cancelEdit}>Cancel</button>
                  </div>
                </div>
              ) : (
                <div className="row spread" style={{ alignItems: 'flex-start', gap: '12px' }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <p style={{ margin: '0 0 4px', fontStyle: 'italic', lineHeight: 1.5 }}>
                      "{q.text}"
                    </p>
                    {q.author && (
                      <span className="info-text">— {q.author}</span>
                    )}
                  </div>
                  <div className="row" style={{ gap: '6px', flexShrink: 0 }}>
                    <button
                      className="secondary"
                      style={{ padding: '4px 8px', fontSize: '12px' }}
                      onClick={() => moveUp(i)}
                      disabled={i === 0}
                      title="Move up"
                    >↑</button>
                    <button
                      className="secondary"
                      style={{ padding: '4px 8px', fontSize: '12px' }}
                      onClick={() => moveDown(i)}
                      disabled={i === config.quotes.length - 1}
                      title="Move down"
                    >↓</button>
                    <button
                      className="secondary"
                      style={{ padding: '4px 8px', fontSize: '12px' }}
                      onClick={() => startEdit(i)}
                    >Edit</button>
                    <button
                      className="secondary"
                      style={{ padding: '4px 8px', fontSize: '12px', color: 'var(--error)' }}
                      onClick={() => deleteQuote(i)}
                    >Delete</button>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Add new quote form */}
        {isAdding ? (
          <div className="card" style={{ borderColor: 'var(--accent)', padding: '14px' }}>
            <h4 style={{ margin: '0 0 10px' }}>New Quote</h4>
            <div className="stack" style={{ gap: '10px' }}>
              <div className="field-group">
                <label>Quote text</label>
                <textarea
                  rows={3}
                  value={draft.text}
                  onChange={(e) => setDraft({ ...draft, text: e.target.value })}
                  placeholder="Enter the quote…"
                  style={{ resize: 'vertical' }}
                  autoFocus
                />
              </div>
              <div className="field-group">
                <label>Author (optional)</label>
                <input
                  type="text"
                  value={draft.author ?? ''}
                  onChange={(e) => setDraft({ ...draft, author: e.target.value })}
                  placeholder="e.g. Sri Guru Granth Sahib Ji"
                />
              </div>
              <div className="row" style={{ gap: '8px' }}>
                <button onClick={commitEdit} disabled={!draft.text.trim()}>Add Quote</button>
                <button className="secondary" onClick={cancelEdit}>Cancel</button>
              </div>
            </div>
          </div>
        ) : (
          <button className="secondary" onClick={startAdd} disabled={editingIndex !== null}>
            + Add Quote
          </button>
        )}

        <p className="info-text" style={{ marginTop: '16px' }}>
          Last saved: {lastPublishedLabel} &nbsp;·&nbsp;
          {saving ? 'Saving…' : dirty ? 'Click "Publish Changes" in the toolbar to save.' : 'Up to date'}
          &nbsp;·&nbsp; {config.quotes.length} quote{config.quotes.length !== 1 ? 's' : ''} total
        </p>
      </div>
    </div>
  )
}
