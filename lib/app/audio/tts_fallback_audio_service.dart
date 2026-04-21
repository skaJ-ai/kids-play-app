/// Temporary implementation of [AudioService] used while real audio assets
/// are still being produced.
///
/// Plays recorded assets when available (via an asset-existence probe) and
/// falls back to device TTS for prompt and child-facing feedback cues.
/// Idle attract / BGM cues still degrade to silence until recorded assets
/// land, but prompt / success / error / reward cues stay audible even when
/// packaged recordings are missing.
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
        await _speech.speak('딩동댕', locale: 'ko-KR', rate: 0.46, pitch: 1.08);
        return;
      case ErrorCue():
        await _speech.speak(
          '어? 다시 해볼까?',
          locale: 'ko-KR',
          rate: 0.46,
          pitch: 0.98,
        );
        return;
      case RewardCue():
        await _speech.speak(
          '스티커 하나 획득!',
          locale: 'ko-KR',
          rate: 0.46,
          pitch: 1.12,
        );
        return;
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
