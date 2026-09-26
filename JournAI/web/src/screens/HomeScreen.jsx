import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import MoodFace from '../components/MoodFace.jsx'
import TabBar from '../components/TabBar.jsx'
import { MOODS } from '../lib/moods.js'
import { useJournalEntries } from '../lib/useJournalEntries.js'
import './HomeScreen.css'

function greeting() {
  const hour = new Date().getHours()
  if (hour < 12) return 'Good morning'
  if (hour < 17) return 'Good afternoon'
  return 'Good evening'
}

export default function HomeScreen() {
  const navigate = useNavigate()
  const { entries, streak } = useJournalEntries()
  const [selectedMood, setSelectedMood] = useState(null)

  const today = new Date().toLocaleDateString(undefined, {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
  })

  return (
    <div className="screen">
      <div className="screen-content home">
        <header className="home__header">
          <div>
            <div className="home__greeting">{greeting().toUpperCase()}</div>
            <h1 className="home__name">Alex</h1>
          </div>
          <div className="home__avatar">A</div>
        </header>

        <div className="home__streak-row">
          <span className="pill pill--tint">
            <FlameIcon />
            {streak > 0 ? `${streak}-day streak` : 'Start your streak today'}
          </span>
          <span className="home__date">{today}</span>
        </div>

        <section className="card home__mood-card">
          <h2 className="home__section-title">How are you, right now?</h2>
          <div className="home__mood-row">
            {MOODS.map((mood) => (
              <MoodFace
                key={mood.id}
                moodId={mood.id}
                selected={selectedMood === mood.id}
                onClick={() => setSelectedMood(mood.id)}
              />
            ))}
          </div>
        </section>

        <section className="home__prompt-card">
          <div className="home__prompt-label">TODAY'S PROMPT</div>
          <p className="home__prompt-text">
            What's one thing you're carrying today that you haven't said out loud?
          </p>
          <button type="button" className="home__prompt-button" onClick={() => navigate('/new-entry')}>
            Start Journaling
            <ArrowIcon />
          </button>
        </section>

        <section className="home__entries">
          <h2 className="home__section-title">Recent Entries</h2>
          {entries.length === 0 ? (
            <p className="home__empty">Your entries will show up here once you start journaling.</p>
          ) : (
            entries.slice(0, 5).map((entry) => (
              <button
                key={entry.id}
                type="button"
                className="card home__entry-row"
                onClick={() => navigate(`/entry/${entry.id}`)}
              >
                <MoodFace moodId={entry.mood} size={36} />
                <div className="home__entry-body">
                  <div className="home__entry-date">
                    {new Date(entry.date)
                      .toLocaleString(undefined, { weekday: 'long', hour: 'numeric', minute: '2-digit' })
                      .toUpperCase()}
                  </div>
                  <p className="home__entry-text">&ldquo;{entry.text}&rdquo;</p>
                  {entry.tags?.[0] && <span className="pill pill--tint home__entry-tag">{entry.tags[0]}</span>}
                </div>
                <ChevronIcon />
              </button>
            ))
          )}
        </section>
      </div>

      <TabBar />
    </div>
  )
}

function FlameIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--accent-dark)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 2c1 4-4 5-4 9a4 4 0 0 0 8 0c0-1.5-1-2-1-3.5 1.5 1 2.5 3 2.5 5.5a5.5 5.5 0 0 1-11 0C6.5 8 9 6 12 2z" />
    </svg>
  )
}

function ArrowIcon() {
  return (
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="var(--accent-dark)" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12h14M13 6l6 6-6 6" />
    </svg>
  )
}

function ChevronIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--ink-faint)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M9 6l6 6-6 6" />
    </svg>
  )
}
