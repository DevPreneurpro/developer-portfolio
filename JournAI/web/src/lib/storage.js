import { useCallback, useRef, useState } from 'react'

/**
 * A useState-like hook backed by localStorage, so settings and entries
 * survive a page reload without needing a backend.
 *
 * Writes happen synchronously inside the setter (not in a useEffect) —
 * a component that sets state and then immediately navigates away (e.g.
 * sign-in, then navigate to /home) can unmount before an effect-based
 * write ever fires, silently losing the update.
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

  const valueRef = useRef(value)
  valueRef.current = value

  const setAndPersist = useCallback(
    (next) => {
      const resolved = typeof next === 'function' ? next(valueRef.current) : next
      valueRef.current = resolved
      try {
        window.localStorage.setItem(key, JSON.stringify(resolved))
      } catch {
        // localStorage unavailable (private mode, quota) — state still works in-memory
      }
      setValue(resolved)
    },
    [key],
  )

  return [value, setAndPersist]
}
