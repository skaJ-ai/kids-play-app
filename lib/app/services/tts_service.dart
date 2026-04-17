import 'package:flutter_tts/flutter_tts.dart';

abstract class TtsService {
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> dispose();
}

class DeviceTtsService implements TtsService {
  DeviceTtsService._();
  static final DeviceTtsService instance = DeviceTtsService._();

  FlutterTts? _tts;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      _tts = FlutterTts();
      await _tts!.setLanguage('ko-KR');
      await _tts!.setSpeechRate(0.45);
      await _tts!.setVolume(1.0);
      _ready = true;
    } catch (_) {}
  }

  @override
  Future<void> speak(String text) async {
    if (!_ready) await init();
    try {
      await _tts?.stop();
      await _tts?.speak(text);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    try {
      await _tts?.stop();
    } catch (_) {}
    _ready = false;
    _tts = null;
  }
}

class NoOpTtsService implements TtsService {
  const NoOpTtsService();

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
