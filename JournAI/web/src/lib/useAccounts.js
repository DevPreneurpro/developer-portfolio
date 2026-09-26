import { useCallback } from 'react'
import { useLocalStorageState } from './storage.js'

// A local-only account list. There's no backend, so this is a prototype
// auth gate for playing with the app — not real security. Seeded with a
// test account so there's always something to log in with.
const DEFAULT_ACCOUNTS = [{ email: 'test@test.com', password: 'test' }]

export function useAccounts() {
  const [accounts, setAccounts] = useLocalStorageState('journai.accounts', DEFAULT_ACCOUNTS)

  const findAccount = useCallback(
    (email) => accounts.find((account) => account.email.toLowerCase() === email.trim().toLowerCase()),
    [accounts],
  )

  const signIn = useCallback(
    (email, password) => {
      const account = findAccount(email)
      if (!account) return { ok: false, error: 'No account found with that email.' }
      if (account.password !== password) return { ok: false, error: 'Incorrect password.' }
      return { ok: true }
    },
    [findAccount],
  )

  const signUp = useCallback(
    (email, password) => {
      const trimmedEmail = email.trim()
      if (!trimmedEmail || !password) {
        return { ok: false, error: 'Enter an email and password.' }
      }
      if (findAccount(trimmedEmail)) {
        return { ok: false, error: 'An account with that email already exists.' }
      }
      setAccounts((prev) => [...prev, { email: trimmedEmail, password }])
      return { ok: true }
    },
    [findAccount, setAccounts],
  )

  return { signIn, signUp }
}
