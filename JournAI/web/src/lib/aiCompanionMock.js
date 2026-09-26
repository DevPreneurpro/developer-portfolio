// Offline fallback used when the backend (server/index.js) can't be reached
// or has no ANTHROPIC_API_KEY configured — canned, rotating responses and a
// keyword-based tagger, so the app still works with no server running.

const FOLLOW_UPS = [
  "That sounds heavy to carry. When you say that, is it more about what happened, or how it's sitting with you now?",
  'Thank you for putting that into words. What do you think you need most right now?',
  'I hear you. Was there a moment today, even a small one, that felt different from that?',
  'That makes sense. What would it look like to be a little kinder to yourself about this tonight?',
  "I'm glad you're telling me this. Want to sit with that thought a bit longer, or move on?",
]

const KEYWORD_TAGS = [
  ['work', 'Work Stress'],
  ['tired', 'Fatigue'],
  ['thank', 'Gratitude'],
  ['grateful', 'Gratitude'],
  ['friend', 'Connection'],
  ['family', 'Family'],
  ['anxious', 'Anxiety'],
  ['sleep', 'Sleep'],
  ['happy', 'Joy'],
  ['love', 'Connection'],
]

function pickRandom(list) {
  return list[Math.floor(Math.random() * list.length)]
}

export function mockReply() {
  return pickRandom(FOLLOW_UPS)
}

export function mockReflect(entryText) {
  const lower = entryText.toLowerCase()
  const tags = []
  for (const [keyword, tag] of KEYWORD_TAGS) {
    if (lower.includes(keyword) && !tags.includes(tag)) {
      tags.push(tag)
    }
  }
  if (tags.length === 0) tags.push('Reflection')

  return {
    reflection:
      "You're carrying a lot right now, but you also put it into words — that's worth coming back to.",
    tags: tags.slice(0, 3),
  }
}
