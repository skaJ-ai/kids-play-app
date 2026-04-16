import 'package:flutter_tts/flutter_tts.dart';

abstract class SpeechCueService {
  Future<void> speak(
    String text, {
    String locale,
    double rate,
    double pitch,
  });

  Future<void> stop();
}

class NoopSpeechCueService implements SpeechCueService {
  @override
  Future<void> speak(
    String text, {
    String locale = 'ko-KR',
    double rate = 0.42,
    double pitch = 1.0,
  }) async {}

  @override
  Future<void> stop() async {}
}

class FlutterTtsSpeechCueService implements SpeechCueService {
  FlutterTtsSpeechCueService(this._flutterTts);

  final FlutterTts _flutterTts;

  @override
  Future<void> speak(
    String text, {
    String locale = 'ko-KR',
    double rate = 0.42,
    double pitch = 1.0,
  }) async {
    if (text.trim().isEmpty) {
      return;
    }

    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(locale);
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.speak(text);
    } catch (_) {
      // Speech is optional; swallow device/plugin issues so toddler flow keeps working.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {
      // ignore
    }
  }
}
