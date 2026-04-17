/// Temporary implementation of [AudioService] used while real audio assets
/// are still being produced.
///
/// Plays recorded assets when available (via an asset-existence probe) and
/// falls back to device TTS for [PromptCue]s. Non-prompt cues (success,
/// error, reward, idle, bgm) degrade to silence when no recording is
/// bundled — screens must always pair audio with visual feedback so silence
/// never blocks the play flow.
library;

import 'dart:async';

import '../services/speech_cue_service.dart';
import 'audio_cue.dart';
import 'audio_service.dart';

typedef AssetProbe = Future<bool> Function(String assetPath);

class TtsFallbackAudioService implements AudioService {
  TtsFallbackAudioService({
    required SpeechCueService speech,
    AssetProbe? assetProbe,
    bool muted = false,
  }) : _speech = speech,
       _assetProbe = assetProbe ?? _alwaysMissing,
       _muted = muted;

  final SpeechCueService _speech;
  final AssetProbe _assetProbe;
  bool _muted;

  @override
  bool get isMuted => _muted;

  @override
  set isMuted(bool value) {
    _muted = value;
    if (value) {
      unawaited(_speech.stop());
    }
  }

  @override
  Future<void> play(AudioCue cue) async {
    if (_muted) return;
    switch (cue) {
      case PromptCue(ref: final ref):
        final hasRecording = await _assetProbe(ref.assetPath);
        if (hasRecording) {
          // Recorded playback is not wired yet (Phase 8); use TTS until then.
        }
        await _speech.speak(ref.fallbackText);
      case SuccessCue():
      case ErrorCue():
      case RewardCue():
      case IdleAttractCue():
      case BgmCue():
        // No asset pipeline yet. Visual feedback at the call site covers the
        // interaction until Phase 8 lands the actual recordings.
        return;
    }
  }

  @override
  Future<void> stop() => _speech.stop();

  static Future<bool> _alwaysMissing(String _) async => false;
}
