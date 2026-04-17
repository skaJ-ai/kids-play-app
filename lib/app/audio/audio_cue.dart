/// Typed audio cues consumed by [AudioService].
///
/// Each variant carries the minimum information the service needs to decide
/// which asset to play and which fallback to take. Raw strings are reserved
/// for [PromptCue] where the TTS fallback needs the text to speak.
library;

import 'package:flutter/foundation.dart';

/// Identifier for a bundle of audio assets belonging to a category / pack
/// (e.g. `alphabet_v1`). Resolved by the audio service to concrete asset
/// paths; never compared against paths directly at the call site.
@immutable
class AudioPackId {
  const AudioPackId(this.value);
  final String value;

  @override
  bool operator ==(Object other) =>
      other is AudioPackId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AudioPackId($value)';
}

/// Logical reference to a recorded audio asset, plus a TTS fallback text.
///
/// The service first tries to play the bundled recording at
/// `assetPath`; if that asset is missing or playback fails, it falls back to
/// speaking [fallbackText] through the device TTS. Callers always provide
/// [fallbackText] so the child flow never goes silent.
@immutable
class AudioCueRef {
  const AudioCueRef({required this.assetPath, required this.fallbackText});

  final String assetPath;
  final String fallbackText;
}

/// Common supertype for all audio cue variants. Use the concrete subclasses
/// at call sites so the service can pattern-match intent.
@immutable
sealed class AudioCue {
  const AudioCue();
}

/// Instructional prompt for the current item — read at item load.
class PromptCue extends AudioCue {
  const PromptCue(this.ref);
  final AudioCueRef ref;
}

/// Positive reinforcement on a correct tap.
class SuccessCue extends AudioCue {
  const SuccessCue({this.tone = SuccessTone.cheer});
  final SuccessTone tone;
}

enum SuccessTone { chime, cheer, sparkle }

/// Short negative signal on a wrong tap. Intentionally gentle.
class ErrorCue extends AudioCue {
  const ErrorCue();
}

/// Reward acquisition celebration. Distinct from success so it can be
/// larger / longer without colliding with per-answer success cues.
class RewardCue extends AudioCue {
  const RewardCue(this.pack);
  final AudioPackId pack;
}

/// Gentle attract loop fired when the child hasn't tapped for a while.
class IdleAttractCue extends AudioCue {
  const IdleAttractCue();
}

/// Background music toggle. [loop] controls whether the track restarts on
/// completion; `false` is one-shot, useful for a lesson-completion jingle.
class BgmCue extends AudioCue {
  const BgmCue({required this.pack, this.loop = true});
  final AudioPackId pack;
  final bool loop;
}
