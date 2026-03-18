# CLEARMARK v2 — Forensic Index

**Repository:** Adomat1/-commoners-code
**Audit Date:** 2026-03-18

---

## Findings by Domain

### Domain A — File Integrity

| # | ID | Type | Finding | Impact | Status |
|---|-----|------|---------|--------|--------|
| 1 | AUD-001 | Format Defect | Sole file is RTF wrapping HTML; not browser-renderable | Critical | Verified |
| 2 | AUD-007 | Format Defect | RTF metadata shows Cocoa/TextEdit export, not code editor output | Medium | Verified |

**Evidence (AUD-001):**
- `{\rtf1\ansi\ansicpg1252\cocoartf2865` (line 1)
- `\f0\fs24 \cf0 <!doctype html>` (line 8)
- CSS braces escaped as `\{` and `\}` throughout

**Evidence (AUD-007):**
- `\cocoartf2865` (line 1)
- `\cocoatextscaling0\cocoaplatform0` (line 2)

---

### Domain B — Content Accuracy

| # | ID | Type | Finding | Impact | Status |
|---|-----|------|---------|--------|--------|
| 3 | AUD-002 | Missing Data | Contact uses placeholder `your-domain.tld` | Critical | Verified |
| 4 | AUD-003 | Contradiction | Tooling described but not present in repo | High | Verified |
| 5 | AUD-004 | Contradiction | Two publications described but not present in repo | High | Verified |

**Evidence (AUD-002):**
- `Email: hello@your-domain.tld` (line 109)
- `Site: https://your-domain.tld` (line 110)

**Evidence (AUD-003):**
- `Scripts and prompts to generate, version, and package PDFs` (line 101)
- Repository contains: 1 file, 0 scripts, 0 npm config

**Evidence (AUD-004):**
- `A 42-page, colour-coded survival planner` (line 91)
- `Chapters 1-6 + Creed, Afterword` (line 96)
- Repository contains: no PDFs, no manuscripts, no source documents

---

### Domain C — Project Completeness

| # | ID | Type | Finding | Impact | Status |
|---|-----|------|---------|--------|--------|
| 6 | AUD-005 | Missing Data | No README, LICENSE, .gitignore, or package.json | Medium | Verified |
| 7 | AUD-006 | Timeline Break | Zero activity for ~5 months since initial commit | Low | Verified |

**Evidence (AUD-005):**
- Repository root contains only `index.html.rtf`

**Evidence (AUD-006):**
- Single commit: 2025-10-19
- Current date: 2026-03-18
- Copyright line: `© 2025 Kyle King`

---

## Critical Links

1. **AUD-001 + AUD-007** — RTF format and Cocoa metadata confirm file was never prepared as deployable HTML
2. **AUD-002 + AUD-003 + AUD-004** — Placeholder contact + missing tooling + missing publications = unsubstantiated portfolio
3. **AUD-005 + AUD-006** — Missing infrastructure + zero activity = abandoned or placeholder repository

---

*CLEARMARK v2 — All 7 findings verified. Confidence: 92%.*
