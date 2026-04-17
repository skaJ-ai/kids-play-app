import 'package:flutter/material.dart';

/// Shared colour tokens for 승원이의 빵빵 놀이터.
///
/// All raw hex values live here so every screen stays in sync.
abstract final class AppColors {
  // ── Sky / background ────────────────────────────────────────
  static const skyTop = Color(0xFFCEECFF);
  static const skyBottom = Color(0xFF7DC8F7);
  static const cream = Color(0xFFFFF8EE);
  static const creamCard = Color(0xFFFFFBF2);

  // ── Text ─────────────────────────────────────────────────────
  static const navy = Color(0xFF1A3A5C);
  static const midBlue = Color(0xFF2E5F8A);
  static const coral = Color(0xFFFF5C78);
  static const orange = Color(0xFFFF7043);

  // ── Category card accents ────────────────────────────────────
  static const hangulTop = Color(0xFFFFCA6C);
  static const hangulBottom = Color(0xFFFF9C42);
  static const alphabetTop = Color(0xFF7DD8FF);
  static const alphabetBottom = Color(0xFF4B98FF);
  static const numberTop = Color(0xFF8EE6A0);
  static const numberBottom = Color(0xFF5DD98D);

  // ── Mode buttons ─────────────────────────────────────────────
  static const learnTop = Color(0xFFFFE55C);
  static const learnBottom = Color(0xFFFFBC00);
  static const gameTop = Color(0xFF8EE6A0);
  static const gameBottom = Color(0xFF38C26A);

  // ── Quiz choice colours (A / B / C / D) ─────────────────────
  static const choiceA = Color(0xFFFFD93D);
  static const choiceAText = navy;
  static const choiceB = Color(0xFFFF6B9D);
  static const choiceBText = Colors.white;
  static const choiceC = Color(0xFF4B98FF);
  static const choiceCText = Colors.white;
  static const choiceD = Color(0xFF5DD98D);
  static const choiceDText = navy;

  // ── Tayo blue palette ────────────────────────────────────────
  static const tayoBlue    = Color(0xFF0094FF);
  static const tayoDark    = Color(0xFF0060CC);
  static const tayoLight   = Color(0xFFB8EEFF);
  static const tayoSuccess = Color(0xFF4CAF50);
  static const tayoError   = Color(0xFFE53935);

  // ── Road decoration ──────────────────────────────────────────
  static const road = Color(0xFF3A3A3A);
  static const roadLine = Color(0xFFFFE040);

  // ── Shadows ──────────────────────────────────────────────────
  static const shadowSoft = Color(0x22000000);
  static const shadowMid = Color(0x33000000);
}
