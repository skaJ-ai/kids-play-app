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
import 'asset_audio_player.dart';
import 'audio_cue.dart';
import 'audio_service.dart';

typedef AssetProbe = Future<bool> Function(String assetPath);

class TtsFallbackAudioService implements AudioService {
  TtsFallbackAudioService({
    required SpeechCueService speech,
    AssetProbe? assetProbe,
    AssetAudioPlayer? assetAudioPlayer,
    bool muted = false,
  }) : _speech = speech,
       _assetProbe = assetProbe ?? _alwaysMissing,
       _assetAudioPlayer = assetAudioPlayer,
       _muted = muted;

  final SpeechCueService _speech;
  final AssetProbe _assetProbe;
  final AssetAudioPlayer? _assetAudioPlayer;
  bool _muted;

  @override
  bool get isMuted => _muted;

  @override
  set isMuted(bool value) {
    _muted = value;
    if (value) {
      unawaited(_speech.stop());
      unawaited(_stopAssetPlayback());
    }
  }

  @override
  Future<void> play(AudioCue cue) async {
    if (_muted) return;
    switch (cue) {
      case PromptCue(ref: final ref):
        final hasRecording = await _assetProbe(ref.assetPath);
        final assetAudioPlayer = _assetAudioPlayer;
        if (hasRecording && assetAudioPlayer != null) {
          await _stopPromptPlayback();
          try {
            await assetAudioPlayer.playAsset(ref.assetPath);
            return;
          } catch (_) {
            // Fall back to TTS so prompts stay audible when asset playback fails.
          }
        }
        await _speech.speak(ref.fallbackText);
        return;
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
  Future<void> stop() => _stopPromptPlayback();

  Future<void> _stopPromptPlayback() => Future.wait<void>([
    _speech.stop(),
    _stopAssetPlayback(),
  ]);

  Future<void> _stopAssetPlayback() async {
    final assetAudioPlayer = _assetAudioPlayer;
    if (assetAudioPlayer == null) {
      return;
    }

    try {
      await assetAudioPlayer.stop();
    } catch (_) {
      // Asset playback is best-effort; ignore stop failures so callers can
      // safely mute/stop and continue to the TTS fallback path.
    }
  }

  static Future<bool> _alwaysMissing(String _) async => false;
}
