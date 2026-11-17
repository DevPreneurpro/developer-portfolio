// Minimal client for Higgsfield's developer REST API — a separate product
// from the consumer Higgsfield app, authenticated with its own API key
// (HIGGSFIELD_KEY_ID + HIGGSFIELD_KEY_SECRET) and billed from its own
// dollar wallet. Docs: https://docs.higgsfield.ai
//
// Honest caveat: direct doc fetches were blocked from this environment, so
// the exact request/response field names below are reconstructed from
// public docs and search results, not verified against a live call. The
// submit → request_id → poll → output_url shape and the `Key ID:SECRET`
// auth header are confirmed by Higgsfield's own FAQ; exact field names
// inside `params` (and where the output URL lives in the status response)
// may need a small adjustment once tested against a real funded key — the
// error messages thrown here include the full response body specifically
// so that first round of debugging is fast.

const BASE_URL = 'https://platform.higgsfield.ai'

function authHeader() {
  const id = process.env.HIGGSFIELD_KEY_ID
  const secret = process.env.HIGGSFIELD_KEY_SECRET
  if (!id || !secret) return null
  return `Key ${id}:${secret}`
}

export function isConfigured() {
  return Boolean(authHeader())
}

async function submit(modelId, params) {
  const auth = authHeader()
  if (!auth) throw new Error('Higgsfield API key not configured')

  const res = await fetch(`${BASE_URL}/${modelId}`, {
    method: 'POST',
    headers: { Authorization: auth, 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  })

  const body = await res.json().catch(() => null)
  if (!res.ok) {
    throw new Error(`Higgsfield submit to ${modelId} failed (${res.status}): ${JSON.stringify(body)}`)
  }

  const requestId = body?.request_id || body?.id
  if (!requestId) {
    throw new Error(`Higgsfield submit to ${modelId} returned no request id: ${JSON.stringify(body)}`)
  }
  return requestId
}

async function pollUntilDone(requestId, { intervalMs = 2000, timeoutMs = 120000 } = {}) {
  const auth = authHeader()
  const deadline = Date.now() + timeoutMs

  while (Date.now() < deadline) {
    const res = await fetch(`${BASE_URL}/requests/${requestId}/status`, {
      headers: { Authorization: auth },
    })
    const body = await res.json().catch(() => null)
    if (!res.ok) {
      throw new Error(`Higgsfield status check for ${requestId} failed (${res.status}): ${JSON.stringify(body)}`)
    }

    const status = body?.status
    if (status === 'completed' || status === 'succeeded') {
      const url = body?.output?.[0]?.url || body?.output?.url || body?.result?.url || body?.url
      if (!url) {
        throw new Error(`Higgsfield request ${requestId} completed but no output URL found: ${JSON.stringify(body)}`)
      }
      return url
    }
    if (status === 'failed' || status === 'error') {
      throw new Error(`Higgsfield request ${requestId} failed: ${JSON.stringify(body)}`)
    }

    await new Promise((resolve) => setTimeout(resolve, intervalMs))
  }

  throw new Error(`Higgsfield request ${requestId} timed out after ${timeoutMs}ms`)
}

export async function generateImage(params, options) {
  const requestId = await submit('soul_2', params)
  return pollUntilDone(requestId, options)
}

export async function generateVideo(params, options) {
  const requestId = await submit('wan2_7', params)
  return pollUntilDone(requestId, { timeoutMs: 180000, ...options })
}
