import { Fragment, useEffect, useRef, useState } from 'react'
import {
  createFaqEntry,
  deleteFaqEntry,
  DeveloperSupport,
  FaqEntry,
  fetchDeveloperSupport,
  fetchFaqEntries,
  fetchPrivacyPolicy,
  fetchSupportRequests,
  PrivacyPolicy,
  saveDeveloperSupport,
  savePrivacyPolicy,
  SupportRequest,
  SupportRequestStatus,
  updateFaqEntry,
  updateSupportRequestStatus,
} from '../../lib/supportService'
import { uploadImageToCloudinary } from '../../lib/cloudinary'
import { auth } from '../../lib/firebase'

function formatDate(value: any) {
  if (!value) return '-'
  if (value?.toDate) return value.toDate().toLocaleString()
  return String(value)
}

export function SupportAdminPanel() {
  const [requests, setRequests] = useState<SupportRequest[]>([])
  const [expandedRequestId, setExpandedRequestId] = useState('')
  const [faqEntries, setFaqEntries] = useState<FaqEntry[]>([])
  const [policy, setPolicy] = useState<PrivacyPolicy>({ title: 'Privacy Policy', content: '' })
  const [loading, setLoading] = useState(false)

  const [devSupport, setDevSupport] = useState<DeveloperSupport>({ upiId: '', upiQrUrl: '', kofiUrl: '' })
  const [devSupportSaving, setDevSupportSaving] = useState(false)
  const [qrUploadProgress, setQrUploadProgress] = useState<number | null>(null)
  const qrFileInputRef = useRef<HTMLInputElement>(null)

  const [newFaq, setNewFaq] = useState<Omit<FaqEntry, 'id'>>({
    question: '',
    answer: '',
    order: 0,
    enabled: true,
  })

  useEffect(() => {
    void load()
  }, [])

  async function load() {
    setLoading(true)
    try {
      const [supportData, faqData, policyData, devSupportData] = await Promise.all([
        fetchSupportRequests(),
        fetchFaqEntries(),
        fetchPrivacyPolicy(),
        fetchDeveloperSupport(),
      ])
      setRequests(supportData)
      setFaqEntries(faqData)
      setPolicy(policyData)
      setDevSupport(devSupportData)
    } finally {
      setLoading(false)
    }
  }

  async function onUploadQrImage(file: File) {
    setQrUploadProgress(0)
    try {
      const result = await uploadImageToCloudinary(file, (p) => setQrUploadProgress(p))
      setDevSupport((prev) => ({ ...prev, upiQrUrl: result.secureUrl }))
    } finally {
      setQrUploadProgress(null)
    }
  }

  async function onSaveDevSupport() {
    setDevSupportSaving(true)
    try {
      await saveDeveloperSupport(
        { upiId: devSupport.upiId, upiQrUrl: devSupport.upiQrUrl, kofiUrl: devSupport.kofiUrl },
        auth.currentUser?.email ?? 'admin',
      )
    } finally {
      setDevSupportSaving(false)
    }
  }

  async function onStatusChange(id: string, status: SupportRequestStatus) {
    await updateSupportRequestStatus(id, status)
    await load()
  }

  async function onCreateFaq() {
    if (!newFaq.question.trim() || !newFaq.answer.trim()) return
    await createFaqEntry({
      ...newFaq,
      question: newFaq.question.trim(),
      answer: newFaq.answer.trim(),
    })
    setNewFaq({ question: '', answer: '', order: 0, enabled: true })
    await load()
  }

  async function onUpdateFaq(entry: FaqEntry) {
    await updateFaqEntry(entry)
    await load()
  }

  async function onDeleteFaq(id: string) {
    if (!confirm('Delete this FAQ?')) return
    await deleteFaqEntry(id)
    await load()
  }

  async function onSavePolicy() {
    await savePrivacyPolicy({ title: policy.title, content: policy.content })
    await load()
  }

  return (
    <div className="stack">
      {loading && <div className="card info-text">Loading support data...</div>}

      <div className="card stack">
        <h3>Developer Support</h3>
        <p className="info-text">Configure payment options shown to users in the Support Development screen.</p>

        <div className="stack">
          <label className="field-label">UPI ID</label>
          <input
            value={devSupport.upiId}
            onChange={(e) => setDevSupport((p) => ({ ...p, upiId: e.target.value }))}
            placeholder="e.g. yourname@upi"
          />
        </div>

        <div className="stack">
          <label className="field-label">UPI QR Image</label>
          {devSupport.upiQrUrl && (
            <img
              src={devSupport.upiQrUrl}
              alt="UPI QR"
              style={{ width: 160, height: 160, objectFit: 'contain', borderRadius: 8, border: '1px solid var(--border)' }}
            />
          )}
          <input
            ref={qrFileInputRef}
            type="file"
            accept="image/*"
            style={{ display: 'none' }}
            onChange={(e) => {
              const file = e.target.files?.[0]
              if (file) void onUploadQrImage(file)
            }}
          />
          <button className="outline" onClick={() => qrFileInputRef.current?.click()} disabled={qrUploadProgress !== null}>
            {qrUploadProgress !== null ? `Uploading… ${qrUploadProgress}%` : 'Upload QR Image'}
          </button>
        </div>

        <div className="stack">
          <label className="field-label">Ko-fi URL</label>
          <input
            value={devSupport.kofiUrl}
            onChange={(e) => setDevSupport((p) => ({ ...p, kofiUrl: e.target.value }))}
            placeholder="e.g. https://ko-fi.com/yourname"
          />
        </div>

        <button onClick={() => void onSaveDevSupport()} disabled={devSupportSaving}>
          {devSupportSaving ? 'Saving…' : 'Save Developer Support'}
        </button>
      </div>

      <div className="card stack">
        <h3>Support Requests</h3>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr>
                <th align="left">Type</th>
                <th align="left">Title</th>
                <th align="left">App</th>
                <th align="left">Platform</th>
                <th align="left">Created</th>
                <th align="left">Status</th>
              </tr>
            </thead>
            <tbody>
              {requests.map((request) => (
                <Fragment key={request.id}>
                  <tr
                    style={{ cursor: 'pointer', borderTop: '1px solid var(--border)' }}
                    onClick={() => setExpandedRequestId(expandedRequestId === request.id ? '' : request.id)}
                  >
                    <td>{request.type}</td>
                    <td>{request.title}</td>
                    <td>{request.appVersion}+{request.buildNumber}</td>
                    <td>{request.platform}</td>
                    <td>{formatDate(request.createdAt)}</td>
                    <td>
                      <select
                        value={request.status}
                        onClick={(e) => e.stopPropagation()}
                        onChange={(e) => void onStatusChange(request.id, e.target.value as SupportRequestStatus)}
                      >
                        <option value="new">new</option>
                        <option value="reviewed">reviewed</option>
                        <option value="resolved">resolved</option>
                      </select>
                    </td>
                  </tr>
                  {expandedRequestId === request.id && (
                    <tr>
                      <td colSpan={6} style={{ background: 'var(--surface)' }}>
                        <div className="stack" style={{ padding: '12px' }}>
                          <div><strong>Message:</strong> {request.message}</div>
                          <div><strong>Email:</strong> {request.email || '-'}</div>
                        </div>
                      </td>
                    </tr>
                  )}
                </Fragment>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="card stack">
        <h3>FAQ</h3>
        <div className="stack">
          <input
            value={newFaq.question}
            onChange={(e) => setNewFaq((p) => ({ ...p, question: e.target.value }))}
            placeholder="Question"
          />
          <textarea
            value={newFaq.answer}
            onChange={(e) => setNewFaq((p) => ({ ...p, answer: e.target.value }))}
            placeholder="Answer"
          />
          <div className="row">
            <input
              type="number"
              value={newFaq.order}
              onChange={(e) => setNewFaq((p) => ({ ...p, order: Number(e.target.value) }))}
              placeholder="Order"
            />
            <label className="row">
              <input
                type="checkbox"
                checked={newFaq.enabled}
                onChange={(e) => setNewFaq((p) => ({ ...p, enabled: e.target.checked }))}
              />
              Enabled
            </label>
            <button onClick={() => void onCreateFaq()}>Add FAQ</button>
          </div>
        </div>

        {faqEntries.map((entry) => (
          <div key={entry.id} className="content-item stack">
            <input
              value={entry.question}
              onChange={(e) => setFaqEntries((list) => list.map((i) => (i.id === entry.id ? { ...i, question: e.target.value } : i)))}
            />
            <textarea
              value={entry.answer}
              onChange={(e) => setFaqEntries((list) => list.map((i) => (i.id === entry.id ? { ...i, answer: e.target.value } : i)))}
            />
            <div className="row spread">
              <div className="row">
                <input
                  type="number"
                  value={entry.order}
                  onChange={(e) => setFaqEntries((list) => list.map((i) => (i.id === entry.id ? { ...i, order: Number(e.target.value) } : i)))}
                />
                <label className="row">
                  <input
                    type="checkbox"
                    checked={entry.enabled}
                    onChange={(e) => setFaqEntries((list) => list.map((i) => (i.id === entry.id ? { ...i, enabled: e.target.checked } : i)))}
                  />
                  Enabled
                </label>
              </div>
              <div className="row">
                <button onClick={() => void onUpdateFaq(entry)}>Save</button>
                <button className="outline danger" onClick={() => void onDeleteFaq(entry.id)}>Delete</button>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="card stack">
        <h3>Privacy Policy</h3>
        <input
          value={policy.title}
          onChange={(e) => setPolicy((p) => ({ ...p, title: e.target.value }))}
          placeholder="Title"
        />
        <textarea
          value={policy.content}
          onChange={(e) => setPolicy((p) => ({ ...p, content: e.target.value }))}
          placeholder="Policy content"
          style={{ minHeight: '280px' }}
        />
        <button onClick={() => void onSavePolicy()}>Save Privacy Policy</button>
      </div>
    </div>
  )
}
