// Talks to the journaling companion. Real replies come from the Express
// server in server/index.js, which calls the Anthropic API with a key that
// lives only in that server's environment — this file never sees the key,
// it just calls same-origin /api/companion/* routes. If the server isn't
// running, or has no ANTHROPIC_API_KEY configured, calls fall back to a
// canned local mock so the app still works.

import { mockReply, mockReflect } from './aiCompanionMock.js'

const OPENERS = [
  "Hey — I'm here. What's on your mind tonight?",
  'Good to see you. How are you actually doing today, underneath the surface?',
  "I'm listening. Start wherever feels right.",
]

export function opener() {
  return OPENERS[Math.floor(Math.random() * OPENERS.length)]
}

export async function reply(conversation, { companionName, personality } = {}) {
  try {
    const res = await fetch('/api/companion/reply', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ messages: conversation, companionName, personality }),
    })
    if (!res.ok) throw new Error(`companion/reply responded ${res.status}`)
    const data = await res.json()
    return data.text
  } catch (error) {
    console.warn('Falling back to offline companion reply:', error.message)
    return mockReply()
  }
}

export async function reflect(entryText) {
  try {
    const res = await fetch('/api/companion/reflect', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: entryText }),
    })
    if (!res.ok) throw new Error(`companion/reflect responded ${res.status}`)
    const data = await res.json()
    return { reflection: data.reflection, tags: data.tags }
  } catch (error) {
    console.warn('Falling back to offline reflection:', error.message)
    return mockReflect(entryText)
  }
}
