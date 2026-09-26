import { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import * as aiCompanion from '../lib/aiCompanionService.js'
import { useJournalEntries } from '../lib/useJournalEntries.js'
import { useSettings } from '../lib/useSettings.js'
import './NewEntryScreen.css'

export default function NewEntryScreen() {
  const navigate = useNavigate()
  const { addEntry } = useJournalEntries()
  const [settings] = useSettings()

  const [messages, setMessages] = useState([])
  const [draft, setDraft] = useState('')
  const [isThinking, setIsThinking] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const bottomRef = useRef(null)
  const openedRef = useRef(false)

  useEffect(() => {
    if (openedRef.current) return
    openedRef.current = true
    setMessages([{ id: crypto.randomUUID(), role: 'ai', text: aiCompanion.opener() }])
  }, [])

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' })
  }, [messages, isThinking])

  const userText = messages
    .filter((message) => message.role === 'user')
    .map((message) => message.text)
    .join(' ')

  async function send() {
    const text = draft.trim()
    if (!text) return
    const nextMessages = [...messages, { id: crypto.randomUUID(), role: 'user', text }]
    setMessages(nextMessages)
    setDraft('')
    setIsThinking(true)
    const responseText = await aiCompanion.reply(nextMessages, {
      companionName: settings.companionName,
      personality: settings.companionPersonality,
    })
    setIsThinking(false)
    setMessages((prev) => [...prev, { id: crypto.randomUUID(), role: 'ai', text: responseText }])
  }

  async function finishEntry() {
    if (!userText) return
    setIsSaving(true)
    const { reflection, tags } = await aiCompanion.reflect(userText)
    const entry = addEntry({ mood: 'neutral', text: userText, reflection, tags })
    setIsSaving(false)
    navigate(`/entry/${entry.id}`, { replace: true })
  }

  function handleKeyDown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      send()
    }
  }

  return (
    <div className="new-entry">
      <header className="new-entry__header">
        <button type="button" className="icon-button" onClick={() => navigate(-1)} aria-label="Back">
          <ChevronLeftIcon />
        </button>
        <div className="new-entry__persona-avatar">
          <SparkleIcon />
        </div>
        <div className="new-entry__persona-info">
          <span className="new-entry__persona-name">{settings.companionName}</span>
          <span className="new-entry__persona-status">listening</span>
        </div>
        <button
          type="button"
          className="new-entry__done"
          onClick={finishEntry}
          disabled={!userText || isSaving}
        >
          {isSaving ? 'Saving…' : 'Done'}
        </button>
      </header>

      <div className="new-entry__messages">
        {messages.map((message) => (
          <div key={message.id} className={`bubble bubble--${message.role}`}>
            {message.text}
          </div>
        ))}
        {isThinking && (
          <div className="bubble bubble--ai bubble--typing">
            <span />
            <span />
            <span />
          </div>
        )}
        <div ref={bottomRef} />
      </div>

      <div className="new-entry__input-bar">
        <textarea
          className="new-entry__input"
          placeholder="Write or speak…"
          rows={1}
          value={draft}
          onChange={(event) => setDraft(event.target.value)}
          onKeyDown={handleKeyDown}
        />
        <button
          type="button"
          className="new-entry__send"
          onClick={send}
          disabled={!draft.trim()}
          aria-label="Send"
        >
          <ArrowUpIcon />
        </button>
      </div>
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

function SparkleIcon() {
  return (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="var(--accent-dark)" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3v4M12 17v4M3 12h4M17 12h4M5.6 5.6l2.8 2.8M15.6 15.6l2.8 2.8M5.6 18.4l2.8-2.8M15.6 8.4l2.8-2.8" />
      <circle cx="12" cy="12" r="3.2" />
    </svg>
  )
}

function ArrowUpIcon() {
  return (
    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="var(--bg)" strokeWidth="2.3" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 19V5M5 12l7-7 7 7" />
    </svg>
  )
}
