# JournAI (web)

The web version of JournAI — React + JavaScript (no TypeScript), plain CSS,
built with Vite. This replaced an earlier Swift/SwiftUI iOS build; the visual
design in [`../design`](../design) is still the reference both were built from.

## Stack

- **React 19** (JavaScript, `.jsx` — no TypeScript)
- **React Router** for navigation between screens
- **Plain CSS** per component (no Tailwind, no CSS-in-JS)
- **Vite** for the dev server and build
- **Express** — a small backend that talks to the real Anthropic API
- **localStorage** for entries and settings — no database, no accounts yet

## Running it

You need two things running at once — the browser app and the small backend
that calls Claude. One command does both:

```bash
cd JournAI/web
npm install
cp .env.example .env      # then edit .env and add your own ANTHROPIC_API_KEY
npm run dev
```

Open the URL Vite prints (usually http://localhost:5173). The Express server
runs on port 8787; Vite proxies `/api/*` requests to it, so the browser only
ever talks to its own origin.

**No `ANTHROPIC_API_KEY`? The app still works.** The New Entry chat and the
after-entry reflection fall back to canned local responses if the server has
no key configured, or isn't reachable at all — see `src/lib/aiCompanionMock.js`.

## Where the AI integration lives — and why the key is never in the browser

- `server/index.js` is the **only** place `ANTHROPIC_API_KEY` is read. It's a
  small Express app with two routes, `/api/companion/reply` and
  `/api/companion/reflect`, that call the Anthropic Messages API
  (`claude-opus-5`) and return plain JSON.
- `src/lib/aiCompanionService.js` is what the React app actually calls. It
  `fetch()`es those same-origin `/api/...` routes — it never sees, stores, or
  sends the API key anywhere itself.

This split matters: an API key embedded in client-side JavaScript ships to
every visitor's browser in plain text (visible in the network tab and in the
page's source), so it must live server-side only. **Never** put a real key in
any file under `src/`, in `vite.config.js`, or in anything committed to git.
`.env` is gitignored for exactly this reason — `.env.example` (no real value)
is the one that's committed.

If a key is ever pasted into a chat, commit message, or anywhere else outside
your own `.env`, treat it as compromised and rotate it in the
[Anthropic Console](https://console.anthropic.com/settings/keys) — a key
that's been typed into a log somewhere isn't safe to keep using even if you
clean it up after the fact.

## Project layout

```
web/
  server/index.js          Express server — the only place the API key is read
  src/
    main.jsx               Entry point, sets up the router
    App.jsx                Routes
    App.css                Shared styles (buttons, cards, pills, dialogs)
    lib/
      aiCompanionService.js  Calls the backend; falls back to the mock
      aiCompanionMock.js     Offline canned responses (no key needed)
      useJournalEntries.js   Entry CRUD + streak, backed by localStorage
      useSettings.js         Settings, backed by localStorage
      storage.js              Generic localStorage-backed useState hook
      moods.js                Mood definitions shared by MoodFace, Home, etc.
    components/
      AppShell.jsx / .css     Centers the app as a phone-width card on desktop
      TabBar.jsx / .css       Bottom nav + the floating "new entry" button
      MoodFace.jsx             The five-mood SVG face, reused everywhere
    screens/
      OnboardingScreen
      HomeScreen
      NewEntryScreen           The chat with the AI companion
      EntryDetailScreen
      SettingsScreen
```

## What's stubbed vs. real

- **Real**: the AI chat and reflection (when `ANTHROPIC_API_KEY` is set), all
  local persistence (entries and settings survive a reload), the streak
  calculation, delete/delete-all.
- **Stubbed**: Onboarding's Apple/email buttons just mark onboarding done —
  there's no real auth. Face ID lock is a settings toggle with no actual
  lock screen behind it yet. The daily reminder time is stored but doesn't
  trigger a real notification.
