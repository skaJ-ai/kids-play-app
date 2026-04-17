# Phase 2.5 — Visual / UX Baseline

**Date:** 2026-04-17
**Status:** Locked in via interview (2026-04-17 evening session).
**Supersedes:** ambient design choices in `2026-04-17_product-overhaul-master-plan.md` §7 and earlier.
**Gates:** Phase 3 (alphabet reference completion) must conform to this document.

---

## 1. Why this doc exists

The master plan locked in *architecture* (common lesson engine, typed audio,
design tokens, central routing) but left *visual language and interaction
grain* unspecified. Phase 2 shipped the engine; the first visual pass looked
dated ("후져보임") and the current audio speaks three variants per card
("에이, 에이, 에이"). Rather than push Phase 3 on top of an unclear visual
contract, this document freezes the product surface before code is written.

The answers below came from a structured Q&A, not from Claude's defaults.

---

## 2. Target user

- **Age:** 2-3 years old, pre-reading.
- **Constraint:** Cannot read Hangul or Latin letters. Voice + image carry
  all meaning. Text is decoration, not a primary channel.
- **Session style:** Short, interruptible, tactile. No penalty for
  "wrong" exploration.

---

## 3. Form factor

- **Landscape phone** is the reference. Portrait is not a v1 target.
- Minimum safe height ≈ 360dp; compact layout must keep branded copy and
  CTA visible without layout exceptions (tested already in
  `hero_screen_test.dart`).

---

## 4. Core interaction model

### Learn mode (탐색)
- Big glyph on the left, mascot on the right.
- Tap the glyph → mascot speaks **a single word** ("에이"), expression
  switches to happy, body jumps (scale 1.0 → 1.15 → 1.0, ~280ms).
- Advance is **manual** — tap the "다음 →" arrow. No auto-advance timer.
- Last card shows "처음부터" instead of "다음".

### Quiz mode (퀴즈)
- Retained for v1.
- **4-choice multiple choice** (2×2 tile grid on the left, mascot on the right).
- Mascot reads the prompt ("에이 찾아봐!") when the question appears.
- Tap a tile → traffic light indicator flips:
  - **Correct → green**, mascot swaps to `1_정답.jpg`, jumps, auto-advance
    after ~900ms.
  - **Wrong → red**, mascot swaps to `2_오답.jpg`, shakes briefly, returns
    to the same question after ~1200ms. No elimination, no timer pressure.
- End of set: if ≥ 80% correct (`earnedSticker`), mascot swaps to
  `3_미션클리어.jpg` and a sticker is awarded.

### Interactions explicitly rejected
- ❌ Auto-advance timers (2-3s, 5s) — user wants dwell time per-child-variable.
- ❌ Read-the-whole-label TTS — only the `spoken` field is vocalized.
- ❌ "Try again" / "Give up" modal buttons — traffic light is the only feedback
  channel.

---

## 5. Mascot system

### Character
- **Giraffe driving a car** (Freepik free-license vector), with the child's
  face overlaid on the giraffe's face. Tayocon personalization.
- One character across all categories — alphabet / hangul / numbers all use
  the same mascot so the child sees themselves as the constant guide.

### Poses (already committed to main branch as `040ba3b`)
| State                | Asset                 | Trigger                                  |
|----------------------|-----------------------|------------------------------------------|
| idle / listening     | `4_기본.png`          | default, during TTS playback             |
| correct / happy      | `1_정답.jpg`          | right answer, card tap success           |
| wrong / surprised    | `2_오답.jpg`          | wrong answer                             |
| set complete         | `3_미션클리어.jpg`    | `earnedSticker == true` at session end   |

**Phase 3 asset task:** move from repo-root (commit 040ba3b) into
`assets/mascot/`, register in `pubspec.yaml`, expose via a `MascotState`
enum + `MascotView` widget. Sync the files into
`/home/openc/kids-play-overhaul/` worktree before implementation starts.

### Reactions on tap (simultaneous)
1. **Speak** — TTS reads `LessonItem.spoken` (a single word).
2. **Expression** — swap PNG to `1_정답.jpg`.
3. **Jump** — Flutter scale tween 1.0 → 1.15 → 1.0, 280ms, `Curves.easeOutBack`.

No GIFs. No Rive. Static PNGs + Flutter motion.

### Face overlay (future refinement)
- Child face cut out and stored separately (`child_face.png`).
- Each pose PNG has a fixed face anchor point; overlay composites at
  render time. Deferred if Phase 3 can ship with the 4 baked-in images.

---

## 6. Feedback mechanism — traffic light

- **Single UI affordance, dual purpose:** thematic (car world) and functional
  (correctness signal).
- Location: top-right of the quiz header, also mirrored large in the center
  during feedback moments.
- States: 🔴 red (wrong), 🟡 yellow (waiting / transition), 🟢 green (correct).
- During learn mode: always yellow (idle, "go whenever").
- No textual "정답!" / "틀렸어!" banner. The light + mascot pose + sound
  cue carry the meaning.

---

## 7. Visual style

### Typography
- **KCC무럭무럭체** for display and title roles (free license, child-targeted,
  thick and rounded).
- Glyph card uses display-scale weight (current: 136-180pt `FontWeight.w900`,
  **KEEP** but re-check with the new font).
- Body copy minimized — any non-essential text should be suppressed on
  compact landscape. The child doesn't read it.

### Background
- Road scene with traffic light. Keep it low-contrast so the glyph remains
  the focus (desaturated sky, soft road gradient, single traffic light on
  the right side of the frame).
- The current `PlaygroundScaffold(showRoad: true)` already has a road motif —
  upgrade its visual fidelity rather than replace.

### Color
- Retain the existing `KidPalette` tokens from Phase 1. No new palette.
- Traffic light uses the palette's green/yellow/red (likely add
  `KidPalette.signalGreen/Yellow/Red` if not present).

### Header
- **Minimize.** Current header shows back button + category pill + progress
  pill. That's already the cap; no adding more.
- On compact landscape, drop the category pill (role is redundant — mascot
  and glyph already communicate category).

---

## 8. Session & navigation

### Session length
- **Full 26 cards, stop-anytime.** No forced 5-card mini-sets.
- Child / parent can exit at any point via back button. `lastViewedIndex` is
  persisted (already implemented via `progressStore.recordLessonIndex`).

### App launch
- **Resume-to-last-played.** The app opens directly into the most recent
  learn or quiz screen the child was on, based on the progress snapshot.
- First-ever launch (no snapshot): fall back to category picker.
- Implementation: boot-time route resolution in `AppRouter` that reads
  `progressStore.loadSnapshot()` and synthesizes a route.

### Navigation model
- Keep the Phase 1 `AppRouter` facade and Option B named routes. No
  `go_router` migration.

---

## 9. Manifest schema rewrite (gates Phase 3)

### Current (broken for 2-3yo TTS)
```json
{
  "symbol": "A",
  "label": "에이, A a",      // TTS reads the whole string → "에이 에이 에이"
  "hint": "사과 (apple)"
}
```

### Target
```json
{
  "symbol": "A",              // identity, used for quiz matching
  "display": "A",             // what's rendered on the glyph card
  "spoken": "에이",           // what TTS says — single word
  "hint": "사과 (apple)"      // kept for parent-facing context
}
```

### Migration
- `LessonItem.fromJson` accepts both shapes; `spoken` falls back to `label`,
  `display` falls back to `symbol` when the new fields are absent.
- Rewrite `assets/generated/manifest/alphabet_lessons.json` first (alphabet
  is the reference).
- Defer hangul / numbers manifests until Phase 5 migration.

---

## 10. Assets inventory — what exists, what's needed

### Already committed (main `040ba3b`)
- `1_정답.jpg`, `2_오답.jpg`, `3_미션클리어.jpg`, `4_기본.png` at repo root.

### Needed for Phase 3
- Move mascot PNGs into `assets/mascot/` and register in `pubspec.yaml`.
- `KCC무럭무럭체.ttf` font file → `assets/fonts/`, wire into
  `KidTypography`.
- Traffic light asset: can be composed from three colored circles +
  signal housing, OR a single SVG. Decide in implementation.
- Updated road background: defer; the existing `PlaygroundScaffold` road
  is acceptable for v1.

### Explicitly out of scope
- Per-letter hand-drawn illustrations.
- Recorded human voice lines (TTS remains the audio path for v1).
- BGM.
- Additional mascot poses beyond the 4 committed.

---

## 11. What Phase 3 implements on top of this

1. **Manifest schema migration** (§9) — one commit.
2. **MascotView widget + MascotState enum** — one commit.
3. **Traffic light widget** (`SignalLight(state: idle|correct|wrong)`) —
   one commit.
4. **GenericLearnScreen rewrite** to the new layout (§4 Learn) —
   mascot on right, glyph on left, next-arrow only, single-word TTS.
5. **GenericQuizScreen rewrite** to the new layout (§4 Quiz) —
   traffic light feedback, mascot pose swaps, no banner.
6. **AppRouter resume-to-last** (§8) — one commit.
7. **Font registration + typography refresh** — one commit.

Each step keeps tests green. The existing widget tests for alphabet
screens will need copy updates; quiz_controller_test.dart stays valid.

---

## 12. Non-goals for this iteration

- Finished illustrations (Phase 3 uses Freepik giraffe + 4 face PNGs).
- Face-cutout compositing system (deferred; 4 baked poses is enough).
- Hangul / numbers visual migration (Phase 5).
- Parent console redesign (Phase 6).
- go_router migration (post-v1).
- Portrait phone support.
- Tablet layout.

---

## 13. Open items parked

- **Freepik licensing** — free tier requires attribution. For a personal
  family app this is fine; if the app is ever published on stores, switch
  to Premium or commission the illustration.
- **Face overlay sourcing** — child face is already in repo-root commits;
  Phase 3 can ship with the 4 pre-composed poses and defer a dynamic face
  overlay system.
- **KCC무럭무럭체 licensing** — verify redistribution terms before shipping
  publicly. Free for personal use is documented.
