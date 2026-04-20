import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/asset_audio_player.dart';
import 'package:kids_play_app/app/audio/audioplayers_asset_audio_player.dart';

class RecordingAssetAudioPlayer implements AssetAudioPlayer {
  final List<({String assetPath, bool loop})> playedRequests = [];
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> playAsset(String assetPath, {bool loop = false}) async {
    playedRequests.add((assetPath: assetPath, loop: loop));
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }

  @override
  Future<void> dispose() async {
    disposeCalls += 1;
  }
}

void main() {
  test('fake asset audio player records play stop and dispose requests', () async {
    final player = RecordingAssetAudioPlayer();

    await player.playAsset(
      'assets/generated/audio/sfx/ui/success_cheer.ogg',
      loop: true,
    );
    await player.stop();
    await player.dispose();

    expect(player.playedRequests, [
      (
        assetPath: 'assets/generated/audio/sfx/ui/success_cheer.ogg',
        loop: true,
      ),
    ]);
    expect(player.stopCalls, 1);
    expect(player.disposeCalls, 1);
  });

  test('audioplayers wrapper normalizes asset paths and delegates lifecycle', () async {
    ReleaseMode? releaseMode;
    String? playedAssetPath;
    var stopCalls = 0;
    var disposeCalls = 0;
    final player = AudioplayersAssetAudioPlayer.test(
      setReleaseMode: (mode) async => releaseMode = mode,
      playNormalizedAsset: (assetPath) async => playedAssetPath = assetPath,
      stop: () async => stopCalls += 1,
      dispose: () async => disposeCalls += 1,
    );

    await player.playAsset('assets/generated/audio/music/garage_loop.ogg', loop: true);
    await player.stop();
    await player.dispose();

    expect(releaseMode, ReleaseMode.loop);
    expect(playedAssetPath, 'generated/audio/music/garage_loop.ogg');
    expect(stopCalls, 1);
    expect(disposeCalls, 1);
  });

  test('audioplayers wrapper preserves normalized paths for one-shot playback', () async {
    ReleaseMode? releaseMode;
    String? playedAssetPath;
    final player = AudioplayersAssetAudioPlayer.test(
      setReleaseMode: (mode) async => releaseMode = mode,
      playNormalizedAsset: (assetPath) async => playedAssetPath = assetPath,
      stop: () async {},
      dispose: () async {},
    );

    await player.playAsset('generated/audio/sfx/ui/error_soft.ogg');

    expect(releaseMode, ReleaseMode.release);
    expect(playedAssetPath, 'generated/audio/sfx/ui/error_soft.ogg');
  });
}
