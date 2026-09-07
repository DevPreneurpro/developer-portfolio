# JournAI — Wireframes (Phase 1)

Live, browsable canvas (all five screens on one pan/zoom board — pinch/scroll
to explore, click into a frame to focus it):

**https://claude.ai/code/artifact/fd5b2c81-8a00-4e3b-b9fe-3821078d344f**

The [`wireframes/`](./wireframes) folder holds the source for each screen as
plain HTML (`.dc.html`) — that's the format the design canvas above renders
from. They're static, high-fidelity mockups (not wired up, not clickable
yet), meant as the visual reference for building the real SwiftUI screens.

## Direction

Warm, calm, personal — this is a private diary with a companion, not a
clinical mood tracker. iOS-native layout conventions throughout: rounded
cards, a plain grouped settings list, a bottom tab bar with a raised
floating "new entry" button, thin SF-Symbols-style line icons drawn as
inline SVG (no emoji).

- **Headlines / journal text:** Source Serif 4 (Google Fonts), falls back to
  Georgia — gives entries and prompts a handwritten-diary feel.
- **UI chrome:** the system sans stack (`-apple-system, SF Pro Text,
  system-ui`) — reads as native iOS, not a web font.
- **Background:** warm off-white cream (`#FBF6F0`), white cards (`#FFFFFF`)
  on a soft `#EAE0D2` hairline border.
- **Ink:** warm near-black (`#2B241F`) for text, `#83766A` / `#B3A99C` for
  secondary and faint text.
- **Accent (one, used sparingly):** warm terracotta — `#C1673E` base,
  `#9C5230` for buttons/dark fills, `#F3DFCF` as a light tint for
  highlighted states and chat bubbles.

## Screens

| # | File | What it's for |
|---|------|----------------|
| 1 | `Onboarding.dc.html` | First screen. Wordmark, tagline, Sign in with Apple / email. |
| 2 | `Main.dc.html` (Home) | Greeting, streak, a quick mood check-in, today's journaling prompt, recent entries. |
| 3 | `NewEntry.dc.html` | The core loop — a chat-style conversation with your AI companion (customizable name/personality), text or voice input. |
| 4 | `EntryDetail.dc.html` | A saved entry: your writing plus a short "AI Reflection" card with mood/theme tags. |
| 5 | `Settings.dc.html` | Account, AI companion customization (name, personality, voice), daily reminder, Face ID lock, export/delete data. |

## Assumptions to revisit

- Static mockups, not an interactive prototype — flag if you'd rather the
  next pass be clickable.
- Companion persona shown here ("Sage", Calm & Curious) is a placeholder;
  the settings screen assumes users can rename it and pick a personality,
  but the actual persona options aren't defined yet.
- Only two tabs (Home, Settings) plus the floating new-entry button — entry
  history is reached via "See all" from Home rather than its own tab, to
  keep the nav minimal at this stage.
