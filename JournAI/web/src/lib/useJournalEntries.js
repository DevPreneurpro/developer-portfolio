import { useCallback, useMemo } from 'react'
import { useLocalStorageState } from './storage.js'

function startOfDay(date) {
  const d = new Date(date)
  d.setHours(0, 0, 0, 0)
  return d.getTime()
}

export function useJournalEntries() {
  const [entries, setEntries] = useLocalStorageState('journai.entries', [])

  const addEntry = useCallback(
    ({ mood, text, reflection, tags }) => {
      const entry = {
        id: crypto.randomUUID(),
        date: new Date().toISOString(),
        mood,
        text,
        reflection,
        tags,
      }
      setEntries((prev) => [entry, ...prev])
      return entry
    },
    [setEntries],
  )

  const deleteEntry = useCallback(
    (id) => {
      setEntries((prev) => prev.filter((entry) => entry.id !== id))
    },
    [setEntries],
  )

  const deleteAll = useCallback(() => {
    setEntries([])
  }, [setEntries])

  const sorted = useMemo(
    () => [...entries].sort((a, b) => new Date(b.date) - new Date(a.date)),
    [entries],
  )

  const streak = useMemo(() => {
    const days = new Set(sorted.map((entry) => startOfDay(entry.date)))
    let day = startOfDay(new Date())
    let count = 0
    const oneDay = 24 * 60 * 60 * 1000
    while (days.has(day)) {
      count += 1
      day -= oneDay
    }
    return count
  }, [sorted])

  const getEntry = useCallback((id) => sorted.find((entry) => entry.id === id), [sorted])

  return { entries: sorted, addEntry, deleteEntry, deleteAll, streak, getEntry }
}
