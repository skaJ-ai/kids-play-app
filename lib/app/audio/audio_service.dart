/// Abstract audio layer consumed by child-facing play screens.
///
/// Replaces ad-hoc `SpeechCueService` calls with a typed cue protocol so
/// screens don't have to know whether a cue resolves to a bundled recording,
/// a TTS utterance, or silence.
library;

import 'dart:async';

import 'audio_cue.dart';

/// Entry point for all audio playback in the app.
///
/// Implementations:
/// - [NoopAudioService] — safe default for tests / asset-free environments.
/// - `TtsFallbackAudioService` — routes through `flutter_tts` when the
///   bundled recording is missing. See `tts_fallback_audio_service.dart`.
/// - `FakeAudioService` (test-only) — records cue invocations for assertion.
abstract class AudioService {
  Future<void> play(AudioCue cue);

  /// Cancel any in-flight cue immediately. Safe to call even if nothing is
  /// playing.
  Future<void> stop();

  /// When `true`, [play] resolves without emitting audio but still respects
  /// the cue contract (e.g. Futures still complete). Visual feedback at the
  /// call site keeps working because screens never depend on audio timing.
  bool get isMuted;
  set isMuted(bool value);
}

/// Does nothing. Useful as a default dependency and in widget tests where
/// audio would add nondeterminism.
class NoopAudioService implements AudioService {
  NoopAudioService({bool muted = true}) : _muted = muted;

  bool _muted;

  @override
  bool get isMuted => _muted;

  @override
  set isMuted(bool value) => _muted = value;

  @override
  Future<void> play(AudioCue cue) async {}

  @override
  Future<void> stop() async {}
}
