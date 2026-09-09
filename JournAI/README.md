# JournAI

An iOS journaling app built around an AI you actually talk to — the same
way people use AI chat as a diary: to put down what's on your mind, work
through a feeling, and have something reflect it back at you. JournAI
turns that into a dedicated, private journaling experience instead of a
general-purpose chat window.

- **Platform:** iOS (Swift / SwiftUI)
- **Status:** Phase 2 — the Onboarding screen is built and runnable in Xcode.
- **This folder** is the project home going forward: [`design/`](./design) has
  the wireframes, [`App/`](./App) has the actual Xcode project.

## Running it on your Mac

1. Clone this repo (or pull if you already have it) and open
   `JournAI/App/JournAI.xcodeproj` in Xcode.
2. Select an iPhone simulator and hit Run (⌘R). `OnboardingView` is the
   screen that launches.
3. To run on your own iPhone: in the project's *Signing & Capabilities* tab,
   pick your personal team under *Team* (Xcode will fix up the bundle
   identifier for you), plug in your phone, and Run.

The Apple/email buttons on Onboarding are visual only right now (marked
`// TODO` in `OnboardingView.swift`) — nothing is wired to real
authentication yet.

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
2. ~~SwiftUI project scaffold~~ ← Onboarding is built, see `App/`
3. Build out Home, New Entry, Entry Detail, Settings in SwiftUI
4. Local persistence for entries (SwiftData / Core Data)
5. AI conversation layer (companion persona, prompts, reflections)
6. Reminders, export, and account/sync
