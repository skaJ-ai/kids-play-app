import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';

void main() {
  test('fallback audio service speaks prompt fallback text through speech cue service', () async {
    final speech = _FakeSpeechCueService();
    final service = FallbackAudioService(speechCueService: speech);

    await service.playPrompt(
      const AudioPromptRequest(
        categoryId: 'numbers',
        lessonId: 'numbers_count_1',
        symbol: '1',
        fallbackText: "'1' 숫자를 찾아봐!",
      ),
    );

    expect(speech.calls, hasLength(1));
    expect(speech.calls.single.text, "'1' 숫자를 찾아봐!");
    expect(speech.calls.single.locale, 'ko-KR');
  });

  test('fallback audio service speaks cue fallback text when provided', () async {
    final speech = _FakeSpeechCueService();
    final service = FallbackAudioService(speechCueService: speech);

    await service.playCue(
      const AudioCue(
        type: AudioCueType.success,
        assetKey: 'audio/sfx/success.ogg',
        fallbackText: '딩동댕',
      ),
    );

    expect(speech.calls, hasLength(1));
    expect(speech.calls.single.text, '딩동댕');
  });

  test('effect cues without spoken fallback stay silent while keeping asset metadata', () async {
    final speech = _FakeSpeechCueService();
    final service = FallbackAudioService(speechCueService: speech);
    const cue = AudioCue(
      type: AudioCueType.success,
      assetKey: 'audio/sfx/success.ogg',
    );

    await service.playCue(cue);

    expect(cue.assetKey, 'audio/sfx/success.ogg');
    expect(speech.calls, isEmpty);
  });

  test('fallback audio service delegates stop to speech cue service', () async {
    final speech = _FakeSpeechCueService();
    final service = FallbackAudioService(speechCueService: speech);

    await service.stop();

    expect(speech.stopCount, 1);
  });

  test('app services auto-wires an audio service when only speech service is injected', () async {
    final speech = _FakeSpeechCueService();
    final services = AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: speech,
    );

    await services.audioService.playPrompt(
      const AudioPromptRequest(
        categoryId: 'numbers',
        lessonId: 'numbers_count_1',
        symbol: '2',
        fallbackText: "'2' 숫자를 찾아봐!",
      ),
    );

    expect(speech.calls, hasLength(1));
    expect(speech.calls.single.text, "'2' 숫자를 찾아봐!");
  });

  test('app services prefers an explicitly injected audio service', () async {
    final speech = _FakeSpeechCueService();
    final audio = _FakeAudioService();
    final services = AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: speech,
      audioService: audio,
    );

    await services.audioService.playPrompt(
      const AudioPromptRequest(
        categoryId: 'numbers',
        lessonId: 'numbers_count_1',
        symbol: '3',
        fallbackText: "'3' 숫자를 찾아봐!",
      ),
    );

    expect(audio.promptCalls, hasLength(1));
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
  final List<AudioPromptRequest> promptCalls = [];
  final List<AudioCue> cueCalls = [];
  int stopCount = 0;

  @override
  Future<void> playCue(AudioCue cue) async {
    cueCalls.add(cue);
  }

  @override
  Future<void> playPrompt(AudioPromptRequest request) async {
    promptCalls.add(request);
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
