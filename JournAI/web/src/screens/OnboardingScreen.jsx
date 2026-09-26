import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAccounts } from '../lib/useAccounts.js'
import { useLocalStorageState } from '../lib/storage.js'
import { CURRENT_USER_KEY, ONBOARDING_KEY } from '../lib/session.js'
import './OnboardingScreen.css'

export default function OnboardingScreen() {
  const navigate = useNavigate()
  const { signIn, signUp } = useAccounts()
  const [, setHasCompletedOnboarding] = useLocalStorageState(ONBOARDING_KEY, false)
  const [, setCurrentUserEmail] = useLocalStorageState(CURRENT_USER_KEY, null)

  const [mode, setMode] = useState('buttons') // 'buttons' | 'signin' | 'signup'
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  function enterApp(userEmail = null) {
    // TODO: replace with real Sign in with Apple auth
    if (userEmail) setCurrentUserEmail(userEmail)
    setHasCompletedOnboarding(true)
    navigate('/home', { replace: true })
  }

  function handleSubmit(event) {
    event.preventDefault()
    setError('')

    const result = mode === 'signup' ? signUp(email, password) : signIn(email, password)
    if (!result.ok) {
      setError(result.error)
      return
    }
    enterApp(email.trim())
  }

  return (
    <div className="onboarding">
      <div className="onboarding__glow" aria-hidden="true" />

      <div className="onboarding__content">
        <div className="onboarding__brand">
          <div className="onboarding__mark">
            <BookIcon />
          </div>
          <h1 className="onboarding__wordmark">
            journ<span>AI</span>
          </h1>
          <p className="onboarding__tagline">Your thoughts, held gently.</p>
        </div>

        <div className="onboarding__actions">
          {mode === 'buttons' ? (
            <>
              <button type="button" className="btn btn--dark" onClick={() => enterApp()}>
                <AppleIcon />
                Continue with Apple
              </button>
              <button
                type="button"
                className="btn btn--outline"
                onClick={() => {
                  setMode('signin')
                  setError('')
                }}
              >
                Continue with Email
              </button>
              <p className="onboarding__legal">By continuing you agree to our Terms &amp; Privacy Policy</p>
            </>
          ) : (
            <form className="onboarding__form" onSubmit={handleSubmit}>
              <button
                type="button"
                className="onboarding__back"
                onClick={() => {
                  setMode('buttons')
                  setError('')
                }}
              >
                <ChevronLeftIcon /> Back
              </button>

              <label className="onboarding__field">
                <span>Email</span>
                <input
                  type="email"
                  required
                  autoFocus
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  placeholder="you@example.com"
                />
              </label>

              <label className="onboarding__field">
                <span>Password</span>
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  placeholder="••••••••"
                />
              </label>

              {error && <p className="onboarding__error">{error}</p>}

              <button type="submit" className="btn btn--dark">
                {mode === 'signup' ? 'Create Account' : 'Sign In'}
              </button>

              <p className="onboarding__signin">
                {mode === 'signup' ? 'Already have an account? ' : "Don't have an account? "}
                <button
                  type="button"
                  className="link-button"
                  onClick={() => {
                    setMode(mode === 'signup' ? 'signin' : 'signup')
                    setError('')
                  }}
                >
                  {mode === 'signup' ? 'Sign in' : 'Create one'}
                </button>
              </p>
            </form>
          )}
        </div>
      </div>
    </div>
  )
}

function BookIcon() {
  return (
    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="var(--accent-dark)" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 6c-1.6-1.4-4-2-6.5-2C4.7 4 4 4.6 4 5.4v12.2c0 .8.7 1.3 1.5 1.2 2.2-.3 4.4.2 6 1.5" />
      <path d="M12 6c1.6-1.4 4-2 6.5-2 .8 0 1.5.6 1.5 1.4v12.2c0 .8-.7 1.3-1.5 1.2-2.2-.3-4.4.2-6 1.5" />
      <path d="M12 6v14" />
    </svg>
  )
}

function AppleIcon() {
  return (
    <svg width="16" height="18" viewBox="0 0 17 20" fill="currentColor">
      <path d="M13.9 10.6c0-2.2 1.8-3.3 1.9-3.4-1-1.5-2.6-1.7-3.2-1.7-1.3-.1-2.6.8-3.2.8-.7 0-1.7-.8-2.9-.8-1.5 0-2.9.9-3.6 2.2-1.6 2.7-.4 6.7 1.1 8.9.7 1.1 1.6 2.3 2.8 2.3 1.1 0 1.5-.7 2.9-.7s1.7.7 2.9.7c1.2 0 2-1.1 2.7-2.2.9-1.3 1.2-2.5 1.2-2.6-.1 0-2.6-1-2.6-3.5zM11.6 3.9c.6-.7 1-1.7.9-2.7-.9 0-1.9.6-2.5 1.3-.5.6-1 1.6-.9 2.6 1 .1 1.9-.5 2.5-1.2z" />
    </svg>
  )
}

function ChevronLeftIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--ink-soft)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M15 6l-6 6 6 6" />
    </svg>
  )
}
