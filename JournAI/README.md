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

Open `App/JournAI.xcodeproj` in Xcode, select an iPhone simulator, and hit
Run (⌘R). See [`App/`](./App) — its `AICompanionService.swift` is still a
local mock (canned responses), not yet wired to a real model.

## What's built

| Screen | iOS | Web |
|---|---|---|
| Onboarding | `OnboardingView.swift` | `OnboardingScreen.jsx` |
| Home | `HomeView.swift` | `HomeScreen.jsx` |
| New Entry (AI chat) | `NewEntryView.swift` (mock AI) | `NewEntryScreen.jsx` (real Claude via backend, falls back to mock) |
| Entry Detail | `EntryDetailView.swift` | `EntryDetailScreen.jsx` |
| Settings | `SettingsView.swift` | `SettingsScreen.jsx` |

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
5. Real AI conversation layer on iOS — replace `MockAICompanionService`
6. Real Sign in with Apple / Google / email auth, on both
7. A real backend + database shared by both apps (today each is local-only
   and the two don't sync with each other)
8. Reminders that actually notify, on both
9. Face ID / passcode lock that actually gates the app, on both
