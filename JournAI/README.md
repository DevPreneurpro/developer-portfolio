# JournAI

An iOS journaling app built around an AI you actually talk to — the same
way people use AI chat as a diary: to put down what's on your mind, work
through a feeling, and have something reflect it back at you. JournAI
turns that into a dedicated, private journaling experience instead of a
general-purpose chat window.

- **Platform:** iOS (Swift / SwiftUI)
- **Status:** Phase 1 — visual design. No app code yet.
- **This folder** is the project home going forward; see [`design/`](./design)
  for the current wireframes.

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
2. SwiftUI project scaffold (screens from the wireframes, no backend)
3. Local persistence for entries (SwiftData / Core Data)
4. AI conversation layer (companion persona, prompts, reflections)
5. Reminders, export, and account/sync
