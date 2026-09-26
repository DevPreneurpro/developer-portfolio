import { useCallback } from 'react'
import { useLocalStorageState } from './storage.js'

const DEFAULT_SETTINGS = {
  companionName: 'Sage',
  companionPersonality: 'Calm & Curious',
  voiceRepliesEnabled: true,
  dailyReminderEnabled: true,
  reminderTime: '21:00',
  faceIdLockEnabled: true,
}

export const PERSONALITIES = ['Calm & Curious', 'Warm & Direct', 'Playful', 'Quiet Listener']

export function useSettings() {
  const [settings, setSettings] = useLocalStorageState('journai.settings', DEFAULT_SETTINGS)

  const update = useCallback(
    (patch) => {
      setSettings((prev) => ({ ...prev, ...patch }))
    },
    [setSettings],
  )

  return [settings, update]
}
