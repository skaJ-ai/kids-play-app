library;

import 'dart:async';

/// Small asset-playback adapter that keeps higher-level audio services decoupled
/// from any specific plugin.
abstract class AssetAudioPlayer {
  /// Plays a bundled Flutter asset.
  ///
  /// Callers may pass either the full Flutter asset path
  /// (`assets/generated/...`) or the plugin-relative path without the leading
  /// `assets/` prefix.
  Future<void> playAsset(String assetPath, {bool loop = false});

  Future<void> stop();

  /// Releases any native/player resources held by this instance.
  Future<void> dispose();
}
