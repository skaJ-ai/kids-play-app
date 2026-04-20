import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/asset_audio_player.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/tts_fallback_audio_service.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';

class _RecordingSpeech implements SpeechCueService {
  _RecordingSpeech({List<String>? events}) : _events = events;

  final List<String>? _events;
  final List<String> spoken = [];
  int stopCalls = 0;

  @override
  Future<void> speak(
    String text, {
    String locale = 'ko-KR',
    double rate = 0.42,
    double pitch = 1.0,
  }) async {
    spoken.add(text);
    _events?.add('speech.speak:$text');
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    _events?.add('speech.stop');
  }
}

class _RecordingAssetAudioPlayer implements AssetAudioPlayer {
  _RecordingAssetAudioPlayer({
    this.playError,
    this.stopError,
    List<String>? events,
  }) : _events = events;

  final Object? playError;
  final Object? stopError;
  final List<String>? _events;
  final List<String> playedAssets = [];
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> playAsset(String assetPath, {bool loop = false}) async {
    playedAssets.add(assetPath);
    _events?.add('asset.play:$assetPath');
    if (playError != null) {
      throw playError!;
    }
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    _events?.add('asset.stop');
    if (stopError != null) {
      throw stopError!;
    }
  }

  @override
  Future<void> dispose() async {
    disposeCalls += 1;
  }
}

void main() {
  group('TtsFallbackAudioService', () {
    test(
      'PromptCue falls through to TTS fallback text when playback is unavailable',
      () async {
        final speech = _RecordingSpeech();
        final service = TtsFallbackAudioService(
          speech: speech,
          assetProbe: (_) async => true,
        );

        await service.play(
          const PromptCue(
            AudioCueRef(
              assetPath: 'assets/generated/audio/voice/prompts/alphabet/a.mp3',
              fallbackText: '에이',
            ),
          ),
        );

        expect(speech.spoken, ['에이']);
      },
    );

    test('prompt uses asset player instead of TTS when asset exists', () async {
      final speech = _RecordingSpeech();
      final assetPlayer = _RecordingAssetAudioPlayer();
      final service = TtsFallbackAudioService(
        speech: speech,
        assetProbe: (_) async => true,
        assetAudioPlayer: assetPlayer,
      );

      await service.play(
        const PromptCue(
          AudioCueRef(
            assetPath: 'assets/generated/audio/voice/prompts/alphabet/a.mp3',
            fallbackText: '에이',
          ),
        ),
      );

      expect(assetPlayer.playedAssets, [
        'assets/generated/audio/voice/prompts/alphabet/a.mp3',
      ]);
      expect(speech.spoken, isEmpty);
    });

    test(
      'asset-backed prompt stops speech and prior asset playback before playback',
      () async {
        final events = <String>[];
        final speech = _RecordingSpeech(events: events);
        final assetPlayer = _RecordingAssetAudioPlayer(events: events);
        const fallbackPrompt = PromptCue(
          AudioCueRef(
            assetPath: 'assets/generated/audio/voice/prompts/alphabet/a.mp3',
            fallbackText: '에이',
          ),
        );
        const recordedPrompt = PromptCue(
          AudioCueRef(
            assetPath: 'assets/generated/audio/voice/prompts/alphabet/b.mp3',
            fallbackText: '비',
          ),
        );
        final service = TtsFallbackAudioService(
          speech: speech,
          assetProbe: (assetPath) async => assetPath == recordedPrompt.ref.assetPath,
          assetAudioPlayer: assetPlayer,
        );

        await service.play(fallbackPrompt);
        await service.play(recordedPrompt);

        expect(speech.spoken, ['에이']);
        expect(speech.stopCalls, 1);
        expect(assetPlayer.stopCalls, 1);
        expect(assetPlayer.playedAssets, [recordedPrompt.ref.assetPath]);

        final playIndex = events.indexOf(
          'asset.play:${recordedPrompt.ref.assetPath}',
        );
        expect(playIndex, greaterThanOrEqualTo(0));
        expect(events.indexOf('speech.stop'), lessThan(playIndex));
        expect(events.indexOf('asset.stop'), lessThan(playIndex));
      },
    );

    test('prompt falls back to TTS if asset playback throws', () async {
      final speech = _RecordingSpeech();
      final assetPlayer = _RecordingAssetAudioPlayer(
        playError: StateError('boom'),
      );
      final service = TtsFallbackAudioService(
        speech: speech,
        assetProbe: (_) async => true,
        assetAudioPlayer: assetPlayer,
      );

      await service.play(
        const PromptCue(
          AudioCueRef(
            assetPath: 'assets/generated/audio/voice/prompts/alphabet/a.mp3',
            fallbackText: '에이',
          ),
        ),
      );

      expect(assetPlayer.playedAssets, [
        'assets/generated/audio/voice/prompts/alphabet/a.mp3',
      ]);
      expect(speech.spoken, ['에이']);
    });

    test('non-prompt cues degrade to silence until assets land', () async {
      final speech = _RecordingSpeech();
      final service = TtsFallbackAudioService(speech: speech);

      await service.play(const SuccessCue());
      await service.play(const ErrorCue());
      await service.play(const RewardCue(AudioPackId('alphabet_v1')));
      await service.play(const IdleAttractCue());
      await service.play(const BgmCue(pack: AudioPackId('alphabet_v1')));

      expect(speech.spoken, isEmpty);
    });

    test('stop stops active speech and asset playback', () async {
      final speech = _RecordingSpeech();
      final assetPlayer = _RecordingAssetAudioPlayer();
      final service = TtsFallbackAudioService(
        speech: speech,
        assetAudioPlayer: assetPlayer,
      );

      await service.stop();

      expect(speech.stopCalls, 1);
      expect(assetPlayer.stopCalls, 1);
    });

    test('stop tolerates asset stop failures', () async {
      final speech = _RecordingSpeech();
      final assetPlayer = _RecordingAssetAudioPlayer(
        stopError: StateError('boom'),
      );
      final service = TtsFallbackAudioService(
        speech: speech,
        assetAudioPlayer: assetPlayer,
      );

      await expectLater(service.stop(), completes);

      expect(speech.stopCalls, 1);
      expect(assetPlayer.stopCalls, 1);
    });

    test(
      'muted service skips all cues and stops active speech and asset playback',
      () async {
        final speech = _RecordingSpeech();
        final assetPlayer = _RecordingAssetAudioPlayer();
        final service = TtsFallbackAudioService(
          speech: speech,
          assetAudioPlayer: assetPlayer,
        );
        service.isMuted = true;

        await service.play(
          const PromptCue(AudioCueRef(assetPath: '', fallbackText: '안녕')),
        );

        expect(speech.spoken, isEmpty);
        expect(speech.stopCalls, greaterThanOrEqualTo(1));
        expect(assetPlayer.playedAssets, isEmpty);
        expect(assetPlayer.stopCalls, greaterThanOrEqualTo(1));
      },
    );

    test('muting tolerates asset stop failures', () async {
      final speech = _RecordingSpeech();
      final assetPlayer = _RecordingAssetAudioPlayer(
        stopError: StateError('boom'),
      );
      final service = TtsFallbackAudioService(
        speech: speech,
        assetAudioPlayer: assetPlayer,
      );

      expect(() => service.isMuted = true, returnsNormally);
      await Future<void>.delayed(Duration.zero);

      expect(speech.stopCalls, 1);
      expect(assetPlayer.stopCalls, 1);
    });
  });
}
