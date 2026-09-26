// Shared localStorage keys + helpers for the (very simple, local-only)
// account system. There's no backend yet — see useAccounts.js — so this is
// a prototype auth gate, not real security.

export const ONBOARDING_KEY = 'journai.hasCompletedOnboarding'
export const CURRENT_USER_KEY = 'journai.currentUserEmail'

export function displayNameFromEmail(email) {
  if (!email) return 'there'
  const localPart = email.split('@')[0]
  const words = localPart
    .replace(/[._-]+/g, ' ')
    .split(' ')
    .filter(Boolean)
  if (words.length === 0) return email
  return words.map((word) => word[0].toUpperCase() + word.slice(1)).join(' ')
}
