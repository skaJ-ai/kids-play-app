library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'asset_audio_player.dart';

class AudioplayersAssetAudioPlayer implements AssetAudioPlayer {
  factory AudioplayersAssetAudioPlayer({AudioPlayer? player}) {
    final resolvedPlayer = player ?? AudioPlayer();
    return AudioplayersAssetAudioPlayer._(
      setReleaseMode: resolvedPlayer.setReleaseMode,
      playNormalizedAsset: (assetPath) =>
          resolvedPlayer.play(AssetSource(assetPath)),
      stopPlayback: resolvedPlayer.stop,
      disposePlayback: resolvedPlayer.dispose,
    );
  }

  @visibleForTesting
  AudioplayersAssetAudioPlayer.test({
    required Future<void> Function(ReleaseMode mode) setReleaseMode,
    required Future<void> Function(String assetPath) playNormalizedAsset,
    required Future<void> Function() stop,
    required Future<void> Function() dispose,
  }) : this._(
         setReleaseMode: setReleaseMode,
         playNormalizedAsset: playNormalizedAsset,
         stopPlayback: stop,
         disposePlayback: dispose,
       );

  const AudioplayersAssetAudioPlayer._({
    required Future<void> Function(ReleaseMode mode) setReleaseMode,
    required Future<void> Function(String assetPath) playNormalizedAsset,
    required Future<void> Function() stopPlayback,
    required Future<void> Function() disposePlayback,
  }) : _setReleaseMode = setReleaseMode,
       _playNormalizedAsset = playNormalizedAsset,
       _stopPlayback = stopPlayback,
       _disposePlayback = disposePlayback;

  final Future<void> Function(ReleaseMode mode) _setReleaseMode;
  final Future<void> Function(String assetPath) _playNormalizedAsset;
  final Future<void> Function() _stopPlayback;
  final Future<void> Function() _disposePlayback;

  @override
  Future<void> playAsset(String assetPath, {bool loop = false}) async {
    await _setReleaseMode(
      loop ? ReleaseMode.loop : ReleaseMode.release,
    );
    await _playNormalizedAsset(normalizeAssetPath(assetPath));
  }

  @override
  Future<void> stop() => _stopPlayback();

  @override
  Future<void> dispose() => _disposePlayback();

  @visibleForTesting
  static String normalizeAssetPath(String assetPath) {
    const assetsPrefix = 'assets/';
    if (assetPath.startsWith(assetsPrefix)) {
      return assetPath.substring(assetsPrefix.length);
    }
    return assetPath;
  }
}
