import { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import MoodFace from '../components/MoodFace.jsx'
import { moodById } from '../lib/moods.js'
import { useJournalEntries } from '../lib/useJournalEntries.js'
import './EntryDetailScreen.css'

export default function EntryDetailScreen() {
  const { entryId } = useParams()
  const navigate = useNavigate()
  const { getEntry, deleteEntry } = useJournalEntries()
  const [confirmingDelete, setConfirmingDelete] = useState(false)

  const entry = getEntry(entryId)

  if (!entry) {
    return (
      <div className="screen">
        <div className="screen-content">
          <p>This entry couldn't be found.</p>
          <button type="button" className="link-button" onClick={() => navigate('/home')}>
            Back to Home
          </button>
        </div>
      </div>
    )
  }

  const date = new Date(entry.date)
  const mood = moodById(entry.mood)

  function handleDelete() {
    deleteEntry(entry.id)
    navigate('/home', { replace: true })
  }

  return (
    <div className="screen">
      <header className="entry-detail__header">
        <button type="button" className="icon-button" onClick={() => navigate(-1)} aria-label="Back">
          <ChevronLeftIcon />
        </button>
        <h1 className="entry-detail__title">
          {date.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })}
        </h1>
        <button
          type="button"
          className="icon-button entry-detail__delete"
          onClick={() => setConfirmingDelete(true)}
          aria-label="Delete entry"
        >
          <TrashIcon />
        </button>
      </header>

      <div className="screen-content entry-detail">
        <div className="entry-detail__meta">
          <MoodFace moodId={entry.mood} size={30} />
          <span className="entry-detail__mood-label">{mood.label}</span>
          <span className="entry-detail__dot">·</span>
          <span className="entry-detail__time">
            {date.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}
          </span>
        </div>

        <p className="entry-detail__text">{entry.text}</p>

        <section className="entry-detail__reflection">
          <div className="entry-detail__reflection-label">
            <SparkleIcon />
            AI REFLECTION
          </div>
          <p className="entry-detail__reflection-text">{entry.reflection}</p>
          {entry.tags?.length > 0 && (
            <div className="entry-detail__tags">
              {entry.tags.map((tag) => (
                <span key={tag} className="entry-detail__tag">
                  {tag}
                </span>
              ))}
            </div>
          )}
        </section>
      </div>

      {confirmingDelete && (
        <div className="confirm-overlay" role="dialog" aria-modal="true">
          <div className="confirm-card">
            <p>Delete this entry? This can't be undone.</p>
            <div className="confirm-actions">
              <button type="button" className="btn btn--outline" onClick={() => setConfirmingDelete(false)}>
                Cancel
              </button>
              <button type="button" className="btn btn--danger" onClick={handleDelete}>
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function ChevronLeftIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--ink)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M15 6l-6 6 6 6" />
    </svg>
  )
}

function TrashIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--danger)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 7h16M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2M18 7l-.8 12a1 1 0 0 1-1 .9H7.8a1 1 0 0 1-1-.9L6 7" />
    </svg>
  )
}

function SparkleIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--accent-dark)" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3v4M12 17v4M3 12h4M17 12h4M5.6 5.6l2.8 2.8M15.6 15.6l2.8 2.8M5.6 18.4l2.8-2.8M15.6 8.4l2.8-2.8" />
    </svg>
  )
}
