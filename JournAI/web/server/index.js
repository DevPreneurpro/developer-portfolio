import 'dotenv/config'
import express from 'express'
import cors from 'cors'
import Anthropic from '@anthropic-ai/sdk'

// This is the ONLY place the Anthropic API key is ever read or used.
// It lives in process.env (from .env, which is gitignored) and never
// reaches the browser — the React app only ever calls this server's
// same-origin /api/* routes.

const PORT = process.env.PORT || 8787
const MODEL = 'claude-opus-5'

const app = express()
app.use(cors({ origin: process.env.ALLOWED_ORIGIN || true }))
app.use(express.json({ limit: '1mb' }))

const apiKey = process.env.ANTHROPIC_API_KEY
const anthropic = apiKey ? new Anthropic({ apiKey }) : null

function requireAnthropic(res) {
  if (!anthropic) {
    res.status(503).json({ error: 'ANTHROPIC_API_KEY is not configured on the server' })
    return false
  }
  return true
}

function firstText(content) {
  return content.find((block) => block.type === 'text')?.text?.trim()
}

app.get('/api/health', (_req, res) => {
  res.json({ configured: Boolean(anthropic) })
})

const companionSystemPrompt = (name, personality) => `You are ${name}, a warm, ${String(
  personality,
).toLowerCase()} AI journaling companion inside an app called JournAI. The person you're \
talking to is journaling out loud to process their day and their feelings — you're a \
thoughtful, present listener in their private diary, not a therapist and not clinical.

Keep replies short — one to three sentences. Be warm, curious, and non-judgmental. Usually \
end with one gentle, open follow-up question, unless the moment calls for just sitting with \
what they said. Never diagnose and never give medical advice. If someone describes thoughts \
of self-harm or being in crisis, gently and clearly encourage them to reach out to a crisis \
line or someone they trust, in addition to anything else you say.`

app.post('/api/companion/reply', async (req, res) => {
  if (!requireAnthropic(res)) return

  try {
    const { messages = [], companionName = 'Sage', personality = 'Calm & Curious' } = req.body ?? {}

    const anthropicMessages = messages
      .filter((message) => message?.role === 'user' || message?.role === 'ai')
      .map((message) => ({
        role: message.role === 'ai' ? 'assistant' : 'user',
        content: String(message.text ?? ''),
      }))

    if (anthropicMessages.length === 0) {
      return res.status(400).json({ error: 'messages must include at least one entry' })
    }

    const response = await anthropic.messages.create({
      model: MODEL,
      max_tokens: 1024,
      system: companionSystemPrompt(companionName, personality),
      thinking: { type: 'adaptive' },
      output_config: { effort: 'low' },
      messages: anthropicMessages,
    })

    res.json({ text: firstText(response.content) || "I'm here — tell me more." })
  } catch (error) {
    console.error('POST /api/companion/reply failed:', error)
    res.status(502).json({ error: 'Failed to reach Claude' })
  }
})

const REFLECT_SYSTEM_PROMPT = `You read one private journal entry and produce a short, warm \
reflection — one to two sentences, non-clinical, never a diagnosis — plus one to three short \
tags summarizing its themes (for example "Work Stress", "Gratitude", "Family"). Respond with \
ONLY valid JSON, no markdown or code fences, exactly matching this shape: \
{"reflection": string, "tags": string[]}`

app.post('/api/companion/reflect', async (req, res) => {
  if (!requireAnthropic(res)) return

  try {
    const { text = '' } = req.body ?? {}
    if (!String(text).trim()) {
      return res.status(400).json({ error: 'text must not be empty' })
    }

    const response = await anthropic.messages.create({
      model: MODEL,
      max_tokens: 512,
      system: REFLECT_SYSTEM_PROMPT,
      thinking: { type: 'adaptive' },
      output_config: { effort: 'low' },
      messages: [{ role: 'user', content: String(text) }],
    })

    const raw = firstText(response.content) ?? '{}'
    let parsed
    try {
      parsed = JSON.parse(raw)
    } catch {
      parsed = {}
    }

    res.json({
      reflection:
        parsed.reflection ||
        "You put something real into words today — that's worth coming back to.",
      tags: Array.isArray(parsed.tags) && parsed.tags.length ? parsed.tags.slice(0, 3) : ['Reflection'],
    })
  } catch (error) {
    console.error('POST /api/companion/reflect failed:', error)
    res.status(502).json({ error: 'Failed to reach Claude' })
  }
})

app.listen(PORT, () => {
  console.log(`JournAI companion server listening on http://localhost:${PORT}`)
  console.log(
    anthropic
      ? 'ANTHROPIC_API_KEY detected — real Claude replies are enabled.'
      : 'No ANTHROPIC_API_KEY set — copy .env.example to .env and add your key to enable real Claude replies.',
  )
})
