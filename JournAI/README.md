# JournAI

An iOS journaling app built around an AI you actually talk to — the same
way people use AI chat as a diary: to put down what's on your mind, work
through a feeling, and have something reflect it back at you. JournAI
turns that into a dedicated, private journaling experience instead of a
general-purpose chat window.

- **Platform:** iOS (Swift / SwiftUI)
- **Status:** Phase 3 — the full app is built and runnable: onboarding,
  home, AI chat journaling, entry detail, and settings, backed by real
  on-device storage.
- **This folder** is the project home going forward: [`design/`](./design) has
  the wireframes, [`App/`](./App) has the actual Xcode project.

## Running it on your Mac

1. Clone this repo (or pull if you already have it) and open
   `JournAI/App/JournAI.xcodeproj` in Xcode.
2. Select an iPhone simulator and hit Run (⌘R).
3. To run on your own iPhone: in the project's *Signing & Capabilities* tab,
   pick your personal team under *Team* (Xcode will fix up the bundle
   identifier for you), plug in your phone, and Run.

Tap either Onboarding button to get in (they're stand-ins for real
Sign in with Apple / email auth — see Roadmap), then use the **+** button
to start journaling. Entries you save show up on Home and persist across
app launches (SwiftData, on-device only, nothing leaves the phone).

## What's built

| Screen | File | Behavior |
|---|---|---|
| Onboarding | `OnboardingView.swift` | Gets you into the app. Auth is stubbed — any button marks onboarding done. |
| Home | `HomeView.swift` | Real streak (computed from entry dates), a mood check-in, today's prompt, and your actual saved entries. |
| New Entry | `NewEntryView.swift` | A real back-and-forth with the AI companion (`AICompanionService`), text input, saves as a `JournalEntry` on "Done". |
| Entry Detail | `EntryDetailView.swift` | Your entry's text, its AI reflection + tags, delete. |
| Settings | `SettingsView.swift` | Companion name/personality/voice, daily reminder time, Face ID lock toggle, delete-all, sign out — all persisted via `@AppStorage`. |

The AI companion (`AICompanionService.swift`) is a mock right now:
canned, rotating responses and a simple keyword-based reflection/tagger —
no network calls, works fully offline. It's written as a protocol
specifically so a real model/backend can be swapped in later without
touching any of the views.

## Core idea

- Journal by writing **or** by talking it out with a customizable AI
  companion (name, personality, voice) that asks gentle follow-up
  questions rather than just logging text.
- Every entry can carry a short AI reflection — themes, mood, a
  summarizing thought — without ever feeling clinical or diagnostic.
- Private by default: local-first data, optional Face ID lock, and a
  straightforward export/delete-everything path.

## Roadmap

1. ~~Wireframes / visual design~~ ← see `design/`
2. ~~SwiftUI project scaffold~~ ← see `App/`
3. ~~Build out Home, New Entry, Entry Detail, Settings~~ ← done, mock AI + local storage
4. ~~Local persistence for entries~~ ← SwiftData, see `JournalEntry.swift`
5. Real AI conversation layer — replace `MockAICompanionService` with an
   actual model/backend call
6. Real Sign in with Apple / email auth
7. Reminders that actually notify (local notifications), export, account/sync
8. Face ID lock that actually gates the app (currently just a settings toggle)
