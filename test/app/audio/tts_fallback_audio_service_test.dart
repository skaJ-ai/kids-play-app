import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/tts_fallback_audio_service.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';

class _RecordingSpeech implements SpeechCueService {
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
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }
}

void main() {
  group('TtsFallbackAudioService', () {
    test('PromptCue falls through to TTS fallback text', () async {
      final speech = _RecordingSpeech();
      final service = TtsFallbackAudioService(speech: speech);

      await service.play(
        const PromptCue(
          AudioCueRef(
            assetPath: 'assets/generated/audio/voice/prompts/alphabet/a.mp3',
            fallbackText: '에이',
          ),
        ),
      );

      expect(speech.spoken, ['에이']);
    });

    test('success, error, and reward cues keep spoken fallbacks', () async {
      final speech = _RecordingSpeech();
      final service = TtsFallbackAudioService(speech: speech);

      await service.play(const SuccessCue());
      await service.play(const ErrorCue());
      await service.play(const RewardCue(AudioPackId('alphabet_v1')));

      expect(speech.spoken, ['딩동댕', '어? 다시 해볼까?', '스티커 하나 획득!']);
    });

    test('idle attract and bgm cues stay silent until assets land', () async {
      final speech = _RecordingSpeech();
      final service = TtsFallbackAudioService(speech: speech);

      await service.play(const IdleAttractCue());
      await service.play(const BgmCue(pack: AudioPackId('alphabet_v1')));

      expect(speech.spoken, isEmpty);
    });

    test('muted service skips all cues and stops active speech', () async {
      final speech = _RecordingSpeech();
      final service = TtsFallbackAudioService(speech: speech);
      service.isMuted = true;

      await service.play(
        const PromptCue(
          AudioCueRef(assetPath: '', fallbackText: '안녕'),
        ),
      );

      expect(speech.spoken, isEmpty);
      expect(speech.stopCalls, greaterThanOrEqualTo(1));
    });
  });
}
