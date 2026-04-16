# Avatar Face Flow Implementation Plan

> For Hermes: use test-driven-development for each production step, and keep changes small enough to validate with widget tests, flutter analyze, and APK builds after each milestone.

Goal: add a parent-only multi-expression face setup flow for 승원이의 빵빵 놀이터, inspired by the reference app’s face feature, so the app can later use the child’s face across home, stories, rewards, and quiz reactions.

Architecture: implement this in layered slices. First add a hidden parent-only entry plus a 5-expression setup shell and domain model. Then add local persistence, image import/capture, and manual crop/edit controls. Finally connect saved expressions to the hero, reward, and quiz surfaces. Keep child-facing screens text-light and reserve setup complexity for the hidden parent flow only.

Tech Stack: Flutter, widget tests, app-private JSON persistence, later image import/crop support via Flutter packages or platform channels if needed.

---

## Scope assumptions

- Parent entry remains hidden behind 5 taps on the hero face area.
- Expression set follows the reference flow:
  - 보통
  - 웃음
  - 슬픔
  - 화남
  - 놀람
- Child-facing UX stays audio-first and simple; all setup complexity stays in parent-only screens.
- First implementation slice should be shippable even before photo capture/editing is finished.

---

## Milestone 1 — parent-only setup shell

### Task 1: Add avatar expression domain model
Objective: define the 5 supported expression slots once so UI, storage, and future avatar rendering all use the same source of truth.

Files:
- Create: lib/features/avatar/domain/avatar_expression.dart
- Test: test/features/avatar/domain/avatar_expression_test.dart

TDD steps:
1. Write failing test for expression count, order, labels, and helper copy.
2. Run: /home/openc/sdk/flutter/bin/flutter test test/features/avatar/domain/avatar_expression_test.dart -v
3. Implement enum + label helpers.
4. Re-run the same test.
5. Commit.

### Task 2: Add parent-only avatar setup screen shell
Objective: create a polished setup screen that explains the 5-expression flow and shows the expression slots in a toddler-safe, parent-facing UI.

Files:
- Create: lib/features/avatar/presentation/avatar_setup_screen.dart
- Test: test/features/avatar/presentation/avatar_setup_screen_test.dart

TDD steps:
1. Write failing widget tests for:
   - title and intro copy
   - all 5 expression slots visible
   - parent-only helper copy shown
   - compact landscape stability
2. Run: /home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart -v
3. Implement minimal screen shell using the current design system.
4. Re-run the widget test.
5. Commit.

### Task 3: Add hidden 5-tap entry from HeroScreen
Objective: let a parent open the setup flow by tapping the hero face area 5 times without exposing extra UI to the child.

Files:
- Modify: lib/features/hero/presentation/hero_screen.dart
- Modify: test/widget_test.dart

TDD steps:
1. Add failing widget test that taps the hero face 5 times and expects the avatar setup screen.
2. Run: /home/openc/sdk/flutter/bin/flutter test test/widget_test.dart --plain-name "opens the avatar setup screen after five taps on the hero face"
3. Convert HeroScreen to stateful if needed and implement tap counting + navigation reset.
4. Re-run the test.
5. Commit.

---

## Milestone 2 — local setup state and completion tracking

### Task 4: Add avatar setup state model
Objective: represent each slot’s completion state and optional saved image path.

Files:
- Create: lib/features/avatar/domain/avatar_expression_slot.dart
- Test: test/features/avatar/domain/avatar_expression_slot_test.dart

### Task 5: Add local manifest repository
Objective: persist the 5 expression slots as app-private JSON so setup survives restarts.

Files:
- Create: lib/features/avatar/data/avatar_profile_repository.dart
- Modify: pubspec.yaml
- Test: test/features/avatar/data/avatar_profile_repository_test.dart

Implementation notes:
- Use app-private storage (path_provider).
- JSON schema should be simple and versionable.
- Keep storage path separate from git-managed assets.

### Task 6: Bind repository state into setup screen
Objective: load saved slot states on entry and show progress/empty states correctly.

Files:
- Modify: lib/features/avatar/presentation/avatar_setup_screen.dart
- Modify: test/features/avatar/presentation/avatar_setup_screen_test.dart

---

## Milestone 3 — photo import/capture and edit flow

### Task 7: Add expression slot actions
Objective: each slot gets actions for 사진 선택/촬영 and later shows saved preview.

Files:
- Modify: lib/features/avatar/presentation/avatar_setup_screen.dart
- Test: test/features/avatar/presentation/avatar_setup_screen_test.dart

### Task 8: Add manual edit/crop screen
Objective: provide a parent-only image edit screen with move, zoom, and rotate controls similar to the reference flow.

Files:
- Create: lib/features/avatar/presentation/avatar_face_editor_screen.dart
- Create: test/features/avatar/presentation/avatar_face_editor_screen_test.dart
- Modify: pubspec.yaml

Implementation notes:
- Keep first version simple: fixed crop frame + pan/zoom/rotate.
- Use one reusable editor for all 5 expressions.
- Save exported PNG/WebP files into app-private storage.

### Task 9: Add face guide screen/copy
Objective: explain why multiple expressions improve the avatar, using parent-friendly visuals/copy.

Files:
- Create: lib/features/avatar/presentation/avatar_face_guide_dialog.dart
- Modify: test/features/avatar/presentation/avatar_setup_screen_test.dart

---

## Milestone 4 — use saved expressions in the app

### Task 10: Use neutral face on hero/home
Objective: replace the current static hero face with the saved neutral expression when available.

Files:
- Modify: lib/features/hero/presentation/hero_screen.dart
- Modify: lib/features/home/presentation/home_screen.dart
- Test: test/widget_test.dart

### Task 11: Use happy/sad/surprised reactions in reward and quiz flow
Objective: connect saved expressions to correct/wrong/reward moments.

Files:
- Modify: lib/features/hangul/presentation/hangul_quiz_screen.dart
- Modify: tests for quiz screen

### Task 12: Add reset/manage controls in parent setup
Objective: allow retake, replace, and reset per slot without exposing complexity to child mode.

Files:
- Modify: lib/features/avatar/presentation/avatar_setup_screen.dart
- Modify: repository tests and widget tests

---

## Verification checklist

After each milestone:
- /home/openc/sdk/flutter/bin/flutter test
- /home/openc/sdk/flutter/bin/flutter analyze
- /home/openc/sdk/flutter/bin/flutter build apk --debug

Before shipping the full face feature:
- Hidden parent entry works reliably.
- All 5 expressions can be saved and reloaded.
- Neutral face is visible on hero/home when configured.
- Correct/reward reactions can swap expressions without layout breakage.
- Setup remains usable in compact landscape.
- Child-facing screens remain simple and text-light.

---

## Immediate next slice to implement now

Implement Milestone 1 only:
1. avatar expression model
2. avatar setup screen shell
3. hidden 5-tap entry from hero face

This provides visible progress quickly, stays dependency-light, and sets up the rest of the face system without overcommitting to capture/edit packages yet.
