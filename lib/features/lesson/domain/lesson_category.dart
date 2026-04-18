import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';

@immutable
class LessonCategoryConfig {
  const LessonCategoryConfig({
    required this.id,
    required this.manifestPath,
    required this.learnHeaderLabel,
    required this.learnHeaderIcon,
    required this.learnSubtitle,
    required this.learnSubtitleCompact,
    required this.quizHeaderLabel,
    required this.quizPromptHeadline,
    required this.quizInstruction,
    required this.quizTargetBadge,
    required this.quizPromptTemplate,
    required this.quizSummaryTitle,
    required this.quizStickerCopy,
    required this.quizStickerMissedCopy,
    required this.accentColor,
    required this.progressKeyPrefix,
  });

  /// Category identifier used in URLs and progress keys (e.g. `alphabet`).
  final String id;

  /// Manifest JSON path under `assets/`.
  final String manifestPath;

  final String learnHeaderLabel;
  final IconData learnHeaderIcon;
  final String learnSubtitle;
  final String learnSubtitleCompact;

  final String quizHeaderLabel;
  final String quizPromptHeadline;
  final String quizInstruction;
  final String quizTargetBadge;

  /// Formatted via `.replaceAll('{symbol}', ...)` to yield the speak prompt.
  final String quizPromptTemplate;

  final String quizSummaryTitle;
  final String quizStickerCopy;
  final String quizStickerMissedCopy;

  final Color accentColor;

  /// Prefix applied when recording per-lesson progress (e.g. `alphabet:`).
  final String progressKeyPrefix;

  String promptFor(String symbol) =>
      quizPromptTemplate.replaceAll('{symbol}', symbol);

  String progressIdFor(String lessonId) => '$progressKeyPrefix$lessonId';
}

const alphabetLessonCategory = LessonCategoryConfig(
  id: 'alphabet',
  manifestPath: 'assets/generated/manifest/alphabet_lessons.json',
  learnHeaderLabel: '알파벳 학습',
  learnHeaderIcon: Icons.school_rounded,
  learnSubtitle: '큰 글자를 보고, 스피커를 눌러 영어 이름도 따라 말해봐요.',
  learnSubtitleCompact: '스피커를 눌러 다시 들어봐요.',
  quizHeaderLabel: '알파벳 게임',
  quizPromptHeadline: '알맞은 알파벳을 찾아보자!',
  quizInstruction: '차근차근 보고, 정답을 콕 눌러봐요.',
  quizTargetBadge: '찾아볼 알파벳',
  quizPromptTemplate: '{symbol} 글자를 찾아봐!',
  quizSummaryTitle: '알파벳 게임 끝!',
  quizStickerCopy: '자동차 스티커 1개 획득!',
  quizStickerMissedCopy: '한 번 더 하면 스티커를 받을 수 있어!',
  accentColor: KidPalette.blue,
  progressKeyPrefix: 'alphabet:',
);
