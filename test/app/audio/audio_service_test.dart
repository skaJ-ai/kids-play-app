import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';

void main() {
  test('app services auto-wire a fallback audio service when only speech is injected', () async {
    final speech = _FakeSpeechCueService();
    final services = AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: speech,
    );

    await services.audioService.play(
      const PromptCue(
        AudioCueRef(assetPath: 'assets/generated/audio/mock.mp3', fallbackText: "'2' 숫자를 찾아봐!"),
      ),
    );

    expect(speech.calls, hasLength(1));
    expect(speech.calls.single.text, "'2' 숫자를 찾아봐!");
  });

  test('auto-wired fallback audio service keeps reward cues audible', () async {
    final speech = _FakeSpeechCueService();
    final services = AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: speech,
    );

    await services.audioService.play(const RewardCue(AudioPackId('numbers')));

    expect(speech.calls, hasLength(1));
    expect(speech.calls.single.text, '스티커 하나 획득!');
  });

  test('app services prefer an explicitly injected audio service', () async {
    final speech = _FakeSpeechCueService();
    final audio = _FakeAudioService();
    final services = AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: speech,
      audioService: audio,
    );

    await services.audioService.play(const SuccessCue());

    expect(audio.cueCalls, hasLength(1));
    expect(audio.cueCalls.single, isA<SuccessCue>());
    expect(speech.calls, isEmpty);
  });
}

class _FakeSpeechCueService implements SpeechCueService {
  final List<_SpeechCall> calls = [];
  int stopCount = 0;

  @override
  Future<void> speak(
    String text, {
    String locale = 'ko-KR',
    double rate = 0.42,
    double pitch = 1.0,
  }) async {
    calls.add(
      _SpeechCall(
        text: text,
        locale: locale,
        rate: rate,
        pitch: pitch,
      ),
    );
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}

class _FakeAudioService implements AudioService {
  final List<AudioCue> cueCalls = [];
  int stopCount = 0;
  bool _muted = false;

  @override
  bool get isMuted => _muted;

  @override
  set isMuted(bool value) => _muted = value;

  @override
  Future<void> play(AudioCue cue) async {
    cueCalls.add(cue);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}

class _SpeechCall {
  const _SpeechCall({
    required this.text,
    required this.locale,
    required this.rate,
    required this.pitch,
  });

  final String text;
  final String locale;
  final double rate;
  final double pitch;
}
