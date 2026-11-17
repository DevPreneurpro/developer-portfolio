# JournAI

An app built around an AI you actually talk to — the same way people use AI
chat as a diary: to put down what's on your mind, work through a feeling,
and have something reflect it back at you. JournAI turns that into a
dedicated, private journaling experience instead of a general-purpose chat
window.

There are two builds of it here, both from the same design:

- **[`App/`](./App)** — the original iOS app (Swift / SwiftUI).
- **[`web/`](./web)** — a web version (React + JavaScript, Express backend,
  real Claude integration).
- **[`design/`](./design)** — the wireframes both were built from.

## Running the web app

```bash
cd web
npm install
cp .env.example .env   # add your own ANTHROPIC_API_KEY
npm run dev
```

See [`web/README.md`](./web/README.md) for the full picture — project
layout, how the AI integration works, and why the API key lives in a small
backend and never in the browser bundle.

## Running the iOS app

The iOS app calls the **same backend** as the web app for real Claude
replies and for companion avatar generation — so start that first:

```bash
cd web
npm install
cp .env.example .env   # add ANTHROPIC_API_KEY, and HIGGSFIELD_KEY_ID/SECRET for avatars
npm run server
```

Then open `App/JournAI.xcodeproj` in Xcode, select an iPhone **simulator**
(it shares your Mac's localhost, so `http://localhost:8787` in
`BackendConfig.swift` just works), and hit Run (⌘R). Testing on a physical
iPhone instead needs your Mac's LAN IP there — see the comment in that file.

No backend running, or no keys configured? The chat still works — it falls
back to canned local replies (`MockAICompanionService.swift`), same
resilience pattern as the web app. Avatar generation (portrait + talking
clips) needs the Higgsfield key specifically; see
[`web/README.md`](./web/README.md) for what that is and how to get one —
it's a separate product/wallet from a regular Higgsfield plan.

## What's built

| Screen | iOS | Web |
|---|---|---|
| Onboarding | `OnboardingView.swift` | `OnboardingScreen.jsx` |
| Home | `HomeView.swift` | `HomeScreen.jsx` |
| New Entry (AI chat) | `NewEntryView.swift` (real Claude via `BackendCompanionService`, falls back to mock) | `NewEntryScreen.jsx` (real Claude via backend, falls back to mock) |
| Entry Detail | `EntryDetailView.swift` | `EntryDetailScreen.jsx` |
| Settings | `SettingsView.swift` (+ `CompanionAppearanceView.swift` — design your companion's look) | `SettingsScreen.jsx` |

**iOS only so far:** a companion appearance editor (`CompanionAppearanceView.swift`)
— pick gender, age, ethnicity, build, hair, eyes, style, accessories, then
generate a portrait and (optionally) two short looping video clips (idle,
talking) via Higgsfield. The clips are generated **once per look** and
reused for every chat — not regenerated per message, since video generation
is slow and costs meaningfully more than a still image.

Both apps persist locally — SwiftData on iOS, localStorage on web — and both
stub authentication (any Onboarding button just gets you in).

## Core idea

- Journal by writing **or** by talking it out with a customizable AI
  companion (name, personality, voice) that asks gentle follow-up
  questions rather than just logging text.
- Every entry can carry a short AI reflection — themes, mood, a
  summarizing thought — without ever feeling clinical or diagnostic.
- Private by default: local-first data, a Face ID/passcode lock setting, and
  a straightforward export/delete-everything path.

## Roadmap

1. ~~Wireframes / visual design~~ ← see `design/`
2. ~~iOS app~~ ← see `App/`
3. ~~Web app~~ ← see `web/`
4. ~~Real AI conversation layer (web)~~ ← `web/server/index.js`, Anthropic API
5. ~~Real AI conversation layer on iOS~~ ← `BackendCompanionService.swift`, same backend
6. ~~Companion avatar: customizable portrait~~ ← `CompanionAppearanceView.swift`, Higgsfield
7. ~~Companion avatar: idle/talking animation~~ ← looping clips, generated once per look
8. Real-time lip-synced video per reply — Higgsfield's `wan2_7` model takes
   a reference image + reference audio, so pairing it with a text-to-speech
   voice could get closer to this, but it's real per-message cost/latency;
   deliberately deferred, not attempted here
9. Same avatar editor on the web app (currently iOS-only)
10. Real Sign in with Apple / Google / email auth, on both
11. A real backend + database shared by both apps (today each is
    local-only and the two don't sync with each other)
12. Reminders that actually notify, on both
13. Face ID / passcode lock that actually gates the app, on both
