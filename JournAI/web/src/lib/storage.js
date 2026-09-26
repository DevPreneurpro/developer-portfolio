import { useCallback, useEffect, useState } from 'react'

/**
 * A useState-like hook backed by localStorage, so settings and entries
 * survive a page reload without needing a backend.
 */
export function useLocalStorageState(key, defaultValue) {
  const [value, setValue] = useState(() => {
    try {
      const stored = window.localStorage.getItem(key)
      return stored !== null ? JSON.parse(stored) : defaultValue
    } catch {
      return defaultValue
    }
  })

  useEffect(() => {
    try {
      window.localStorage.setItem(key, JSON.stringify(value))
    } catch {
      // localStorage unavailable (private mode, quota) — state still works in-memory
    }
  }, [key, value])

  return [value, setValue]
}

export function useLocalStorageFlag(key, defaultValue = false) {
  const [value, setValue] = useLocalStorageState(key, defaultValue)
  const set = useCallback((next) => setValue(next), [setValue])
  return [value, set]
}
