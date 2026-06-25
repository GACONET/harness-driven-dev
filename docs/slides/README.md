# HDD Slides — TED-style

Reveal.js presentation for **"Shift-Left Meets Agentic AI: Orquestación con Harness para Equipos de Desarrollo Modernos"**.

## Design philosophy

These slides are designed following Chris Anderson's TED Talks method:

1. **Throughline (15 words)**: *"Quality shouldn't depend on willpower. It should be the default behavior."*
2. **One idea per slide** — slides are visual anchors, not the script.
3. **Speaker says everything else** — the full word-by-word script lives in `<aside class="notes">` on each slide.
4. **Ken Robinson 5-part arc**: Introduction → Context → Concepts → Implications → Conclusion.
5. **Less is more**: 21 slides instead of 35. Brené Brown's advice: *"Plan your talk, then cut it in half. Then cut it in half again."*

## Run locally

```bash
# Option 1: simplest
open docs/slides/index.html

# Option 2: serve locally (recommended for QR + speaker view)
cd docs/slides
python3 -m http.server 8000
# → http://localhost:8000
```

## Speaker view

Press `s` during the presentation. You will see:

- Current slide (left)
- Next slide preview (right)
- **Full speaker notes** with the word-by-word script, timing, gestures, fallback plans
- Timer

The notes are embedded in each `<section>` as `<aside class="notes">`. They include:

- ⏱ target time per slide
- What to say (literal text)
- When to pause
- When to click for fragments
- What to do if a demo fails
- Transition to the next slide

## Navigation

- `→` / `Space` — next
- `←` — previous
- `s` — speaker notes view
- `f` — fullscreen
- `Esc` — overview
- `b` / `.` — black out screen (use during demos)

## Structure (21 slides, ~59 min + Q&A)

| Block | Slides | Time | Function |
|-------|--------|------|----------|
| A — Opening (connection) | 1–4 | 5 min | Vulnerability + throughline |
| B — Why it matters | 5–7 | 7 min | The gap + the cost |
| C — Concepts | 8–13 | 14 min | Harness + 6 layers + restaurant analogy + system components |
| D — Live demos | 14–17 | 25 min | Secret blocked / CI bug / PR approval |
| E — Close | 18–21 | 8 min | Before/after + key lesson + future + thanks |

## Layout

- `index.html` — 21 slides with embedded speaker notes
- `styles.css` — TED-style minimal CSS (one idea per slide, large fonts)
- `assets/` — video and fallback assets for presentation slides
