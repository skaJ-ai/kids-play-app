/// Product-wide design tokens.
///
/// Use these instead of inline magic numbers on every child-facing screen.
/// Existing magic numbers in legacy screens are migrated phase by phase.
library;

import 'package:flutter/widgets.dart';

/// Spacing scale (logical pixels).
abstract final class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 14.0;
  static const l = 20.0;
  static const xl = 28.0;
  static const xxl = 40.0;
}

/// Corner-radius scale (logical pixels).
abstract final class Corner {
  static const sm = 10.0;
  static const md = 18.0;
  static const lg = 28.0;
  static const xl = 36.0;
  static const pill = 999.0;
}

/// Motion / animation durations.
abstract final class Motion {
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 160);
  static const base = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 420);
  static const slower = Duration(milliseconds: 640);
}

/// Opacity scale. Named so reviewers can see intent instead of `0.58`.
abstract final class Opac {
  static const faint = 0.32;
  static const subtle = 0.58;
  static const muted = 0.76;
  static const strong = 0.88;
  static const solid = 0.94;
}

/// Stroke widths for outlines / dividers.
abstract final class Stroke {
  static const hairline = 0.5;
  static const thin = 1.0;
  static const regular = 1.5;
  static const thick = 2.5;
}

/// Layout breakpoints for the child-facing play shell.
///
/// These correspond to the compact landscape regime the 27-month target
/// device runs on, plus a tablet-class upper bound used by parent screens.
abstract final class Breakpoint {
  /// Below this short-side, layouts must collapse to a tight, single-column,
  /// keyboard-avoiding variant.
  static const tight = 360.0;

  /// The default compact landscape child-play width.
  static const compact = 640.0;

  /// Parent / tablet-class width above which extra density is allowed.
  static const roomy = 900.0;
}

/// Z-index tokens for overlay stacking order. Raw values, not enum, so they
/// interop with Flutter's int `elevation` where needed.
abstract final class Z {
  static const base = 0;
  static const raised = 2;
  static const overlay = 8;
  static const modal = 16;
  static const toast = 24;
}

/// Convenience helpers built on the primitive tokens above. Keeps call sites
/// declarative instead of hand-constructing [EdgeInsets] everywhere.
abstract final class Insets {
  static const cardPaddingTight = EdgeInsets.all(Space.m);
  static const cardPaddingRegular = EdgeInsets.all(Space.l);
  static const cardPaddingRoomy = EdgeInsets.all(Space.xl);
  static const pagePaddingTight = EdgeInsets.symmetric(
    horizontal: Space.l,
    vertical: Space.m,
  );
  static const pagePaddingRegular = EdgeInsets.symmetric(
    horizontal: Space.xl,
    vertical: Space.l,
  );
}
