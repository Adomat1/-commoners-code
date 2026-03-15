# The Commoner's Code

## Project Overview

Personal portfolio and verification site for Kyle King — modern field manuals, resilient design systems, and AI-assisted publishing.

## Tech Stack

- Static HTML/CSS (no build tools or JS frameworks)
- Google Fonts: Inter (300, 400, 600) and Manrope (700, 800)
- CSS custom properties for theming
- Dark mode via `prefers-color-scheme` media query

## File Structure

- `index.html` — Main portfolio page (single-page site)
- `.zed/settings.json` — Zed editor configuration with Claude assistant

## Style Guidelines

- British English spelling (colour, organised, etc.)
- Semantic HTML, no unnecessary wrappers
- CSS: use existing custom properties (`--bg`, `--fg`, `--muted`, `--sage`, `--rust`, `--mist`, `--sand`, `--line`)
- Keep it minimal — no JavaScript unless absolutely necessary
- Mobile-first responsive design using CSS Grid

## Key Projects Referenced

1. **The Commoner's Ledger** — 42-page survival planner (15 sections)
2. **The Commoner's Code — Field Manual I** — Chapters 1–6 with appendices
3. **Tooling** — Claude Code scripts for PDF generation and versioning
