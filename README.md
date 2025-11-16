# Nyxara 2030 Guide — Design Files

Complete dark, modern Nyxara-style layout for "GET AHEAD OF THE GAME — 2030 Guide (Nyxara Edition)"

## Files Included

1. **nyxara-watermark.svg** — White serpent + crown watermark (600×600)
2. **nyxara-a4-guide.html** — Full A4 designed guide (7 pages, print-ready)
3. **nyxara-slides.html** — 16:9 slide deck (16 slides, presentation-ready)

## Design Specifications

### Style System
- **Color Palette:** Pure black (#000000), deep charcoal (#1a1a1a), obsidian (#0d0d0d), pearl white (#f5f5f5)
- **Accent:** Gold (#d4af37) with glow effects
- **Typography:**
  - Headings: Playfair Display (serif, 400/700/900)
  - Body: Inter (sans-serif, 300/400/600/700)
- **Layout:** 12-column grid, clean spacing, minimal elements
- **Mood:** Elite, arcane, disciplined, technical

### Watermark Implementation
- **A4 Guide:** 400×400px at 12% opacity, centered with faint glow
- **Slides:** 120×120px at 15% opacity, bottom-center with glow
- **Effect:** Drop-shadow with gold glow (#d4af37 with 30-40% opacity)

## Viewing the Files

### In Browser
Simply open the HTML files in any modern web browser:

```bash
# On macOS
open nyxara-a4-guide.html
open nyxara-slides.html

# On Linux
xdg-open nyxara-a4-guide.html
xdg-open nyxara-slides.html

# On Windows
start nyxara-a4-guide.html
start nyxara-slides.html
```

### Important Notes
- All files must be in the same directory for watermark to display
- Fonts load from Google Fonts (requires internet connection)
- Background gradients and colors are print-optimized

## Exporting to PDF

### Method 1: Browser Print (Recommended)

**For A4 Guide:**
1. Open `nyxara-a4-guide.html` in Chrome/Edge/Brave
2. Press `Ctrl/Cmd + P` to open Print dialog
3. Settings:
   - Destination: Save as PDF
   - Paper size: A4
   - Margins: None
   - Scale: 100%
   - ✅ Background graphics
4. Save as: `Nyxara-2030-Guide-A4.pdf`

**For Slides:**
1. Open `nyxara-slides.html` in Chrome/Edge/Brave
2. Press `Ctrl/Cmd + P` to open Print dialog
3. Settings:
   - Destination: Save as PDF
   - Paper size: Custom (1920×1080px or 16:9)
   - Margins: None
   - Scale: 100%
   - ✅ Background graphics
4. Save as: `Nyxara-2030-Guide-Slides.pdf`

### Method 2: Command Line (macOS/Linux)

Install `wkhtmltopdf`:

```bash
# macOS
brew install wkhtmltopdf

# Ubuntu/Debian
sudo apt-get install wkhtmltopdf
```

Generate PDFs:

```bash
# A4 Guide
wkhtmltopdf --enable-local-file-access \
  --page-size A4 \
  --margin-top 0 \
  --margin-bottom 0 \
  --margin-left 0 \
  --margin-right 0 \
  nyxara-a4-guide.html \
  Nyxara-2030-Guide-A4.pdf

# Slides (requires custom page size)
wkhtmltopdf --enable-local-file-access \
  --page-width 1920px \
  --page-height 1080px \
  --margin-top 0 \
  --margin-bottom 0 \
  --margin-left 0 \
  --margin-right 0 \
  nyxara-slides.html \
  Nyxara-2030-Guide-Slides.pdf
```

### Method 3: Puppeteer (Node.js)

Create `export-pdf.js`:

```javascript
const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();

  // Export A4 Guide
  await page.goto(`file://${path.resolve('nyxara-a4-guide.html')}`, {
    waitUntil: 'networkidle0'
  });
  await page.pdf({
    path: 'Nyxara-2030-Guide-A4.pdf',
    format: 'A4',
    printBackground: true,
    margin: { top: 0, bottom: 0, left: 0, right: 0 }
  });

  // Export Slides
  await page.goto(`file://${path.resolve('nyxara-slides.html')}`, {
    waitUntil: 'networkidle0'
  });
  await page.pdf({
    path: 'Nyxara-2030-Guide-Slides.pdf',
    width: '1920px',
    height: '1080px',
    printBackground: true,
    margin: { top: 0, bottom: 0, left: 0, right: 0 }
  });

  await browser.close();
  console.log('✅ PDFs exported successfully');
})();
```

Run:

```bash
npm install puppeteer
node export-pdf.js
```

## Content Structure

### A4 Guide (7 Pages)
1. **Cover Page** — Title, edition mark, large watermark
2. **Introduction** — Purpose, audience, usage guide
3. **I. The Technological Landscape** — AI, Web3, Quantum Computing
4. **II. The Economic Shift** — Career evolution, micro-credentials, financial resilience
5. **III. Skills & Capabilities** — Technical literacy, communication, critical thinking
6. **IV. Health & Resilience** — Physical foundations, mental resilience, environment design
7. **V. Social & Political Awareness + Action Plan** — Privacy, community, 90-day roadmap

### Slide Deck (16 Slides)
1. Cover
2. Introduction
3. Who This Is For
4. AI Landscape
5. Decentralization & Web3
6. Economic Shift
7. Micro-Credentials
8. Financial Resilience
9. Technical Literacy
10. Communication Precision
11. Critical Thinking
12. Health Foundations
13. Mental Resilience
14. Privacy as Power
15. Community & Mutual Aid
16. 90-Day Action Plan
17. Final Message

## Customization

### Changing Colors
Edit CSS variables in `<style>` section:

```css
:root {
  --black: #000000;
  --charcoal: #1a1a1a;
  --obsidian: #0d0d0d;
  --pearl: #f5f5f5;
  --pearl-muted: #cccccc;
  --accent-gold: #d4af37;
  --glow: rgba(212, 175, 55, 0.3);
}
```

### Changing Content
Edit HTML directly within `<div class="content">` sections.

### Adjusting Watermark
Modify `.watermark` CSS properties:
- `opacity` — Transparency (0.1–0.2 recommended)
- `width/height` — Size
- `filter: drop-shadow()` — Glow effect

## Technical Notes

- **Print Color Accuracy:** Uses `-webkit-print-color-adjust: exact` and `print-color-adjust: exact`
- **Page Breaks:** Controlled via `page-break-after: always`
- **Responsive:** Fixed dimensions for print consistency
- **Cross-browser:** Tested in Chrome, Firefox, Edge, Safari

## Brand Consistency

All files maintain the **Nyxara brand identity**:
- Dark, arcane aesthetic
- Premium, professional tone
- Clear hierarchy and spacing
- Embossed/glowing effects on key elements
- Consistent use of serpent + crown watermark

---

**Created for:** Nyxara Design System
**Format:** HTML/CSS → PDF Export
**Print-Ready:** A4 (210×297mm) + Slides (1920×1080px)
**License:** All rights reserved
