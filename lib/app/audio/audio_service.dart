import '../services/speech_cue_service.dart';
import 'audio_cue.dart';

abstract class AudioService {
  Future<void> playPrompt(AudioPromptRequest request);

  Future<void> playCue(AudioCue cue);

  Future<void> stop();
}

class FallbackAudioService implements AudioService {
  const FallbackAudioService({required SpeechCueService speechCueService})
    : _speechCueService = speechCueService;

  final SpeechCueService _speechCueService;

  @override
  Future<void> playPrompt(AudioPromptRequest request) async {
    if (request.fallbackText.trim().isEmpty) {
      return;
    }

    await _speechCueService.speak(
      request.fallbackText,
      locale: request.locale,
      rate: request.rate,
      pitch: request.pitch,
    );
  }

  @override
  Future<void> playCue(AudioCue cue) async {
    final fallbackText = cue.fallbackText;
    if (fallbackText == null || fallbackText.trim().isEmpty) {
      return;
    }

    await _speechCueService.speak(
      fallbackText,
      locale: cue.locale,
      rate: cue.rate,
      pitch: cue.pitch,
    );
  }

  @override
  Future<void> stop() {
    return _speechCueService.stop();
  }
}
