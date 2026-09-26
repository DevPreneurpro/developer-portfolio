import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import TabBar from '../components/TabBar.jsx'
import { useLocalStorageState } from '../lib/storage.js'
import { useJournalEntries } from '../lib/useJournalEntries.js'
import { PERSONALITIES, useSettings } from '../lib/useSettings.js'
import { CURRENT_USER_KEY, ONBOARDING_KEY, displayNameFromEmail } from '../lib/session.js'
import './SettingsScreen.css'

export default function SettingsScreen() {
  const navigate = useNavigate()
  const [settings, updateSettings] = useSettings()
  const { entries, deleteAll } = useJournalEntries()
  const [, setHasCompletedOnboarding] = useLocalStorageState(ONBOARDING_KEY, false)
  const [currentUserEmail, setCurrentUserEmail] = useLocalStorageState(CURRENT_USER_KEY, null)
  const [confirmingDeleteAll, setConfirmingDeleteAll] = useState(false)

  function signOut() {
    setHasCompletedOnboarding(false)
    setCurrentUserEmail(null)
    navigate('/onboarding', { replace: true })
  }

  const displayName = displayNameFromEmail(currentUserEmail)

  return (
    <div className="screen">
      <div className="screen-content settings">
        <h1 className="settings__title">Settings</h1>

        <div className="card settings__account">
          <div className="settings__avatar">{displayName[0]?.toUpperCase() ?? '?'}</div>
          <div>
            <div className="settings__account-name">{displayName}</div>
            <div className="settings__account-email">{currentUserEmail ?? 'Signed in with Apple'}</div>
          </div>
        </div>

        <section>
          <h2 className="settings__section-title">AI COMPANION</h2>
          <div className="card settings__group">
            <div className="settings__row">
              <span className="settings__row-label">Companion Name</span>
              <input
                className="settings__input"
                type="text"
                value={settings.companionName}
                onChange={(event) => updateSettings({ companionName: event.target.value })}
              />
            </div>
            <div className="settings__divider" />
            <div className="settings__row">
              <span className="settings__row-label">Personality</span>
              <select
                className="settings__select"
                value={settings.companionPersonality}
                onChange={(event) => updateSettings({ companionPersonality: event.target.value })}
              >
                {PERSONALITIES.map((option) => (
                  <option key={option} value={option}>
                    {option}
                  </option>
                ))}
              </select>
            </div>
            <div className="settings__divider" />
            <div className="settings__row">
              <span className="settings__row-label">Voice Replies</span>
              <Toggle
                checked={settings.voiceRepliesEnabled}
                onChange={(value) => updateSettings({ voiceRepliesEnabled: value })}
              />
            </div>
          </div>
        </section>

        <section>
          <h2 className="settings__section-title">REMINDERS</h2>
          <div className="card settings__group">
            <div className="settings__row">
              <span className="settings__row-label">Daily Check-in</span>
              <Toggle
                checked={settings.dailyReminderEnabled}
                onChange={(value) => updateSettings({ dailyReminderEnabled: value })}
              />
            </div>
            {settings.dailyReminderEnabled && (
              <>
                <div className="settings__divider" />
                <div className="settings__row">
                  <span className="settings__row-label">Reminder Time</span>
                  <input
                    className="settings__input settings__input--time"
                    type="time"
                    value={settings.reminderTime}
                    onChange={(event) => updateSettings({ reminderTime: event.target.value })}
                  />
                </div>
              </>
            )}
          </div>
        </section>

        <section>
          <h2 className="settings__section-title">PRIVACY &amp; DATA</h2>
          <div className="card settings__group">
            <div className="settings__row">
              <span className="settings__row-label">Face ID / Passcode Lock</span>
              <Toggle
                checked={settings.faceIdLockEnabled}
                onChange={(value) => updateSettings({ faceIdLockEnabled: value })}
              />
            </div>
            <div className="settings__divider" />
            <button
              type="button"
              className="settings__row settings__row--button"
              onClick={() => setConfirmingDeleteAll(true)}
            >
              <span className="settings__row-label settings__danger-text">
                Delete All Entries ({entries.length})
              </span>
            </button>
          </div>
        </section>

        <button type="button" className="settings__signout" onClick={signOut}>
          Sign Out
        </button>
      </div>

      <TabBar />

      {confirmingDeleteAll && (
        <div className="confirm-overlay" role="dialog" aria-modal="true">
          <div className="confirm-card">
            <p>Delete all {entries.length} entries? This can't be undone.</p>
            <div className="confirm-actions">
              <button type="button" className="btn btn--outline" onClick={() => setConfirmingDeleteAll(false)}>
                Cancel
              </button>
              <button
                type="button"
                className="btn btn--danger"
                onClick={() => {
                  deleteAll()
                  setConfirmingDeleteAll(false)
                }}
              >
                Delete Everything
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function Toggle({ checked, onChange }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      className={`toggle ${checked ? 'is-on' : ''}`}
      onClick={() => onChange(!checked)}
    >
      <span className="toggle__knob" />
    </button>
  )
}
