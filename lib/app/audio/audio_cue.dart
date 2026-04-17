enum AudioCueType { prompt, success, error, reward, tap }

class AudioPromptRequest {
  const AudioPromptRequest({
    required this.categoryId,
    required this.lessonId,
    required this.symbol,
    required this.fallbackText,
    this.assetKey,
    this.locale = 'ko-KR',
    this.rate = 0.42,
    this.pitch = 1.0,
  });

  final String categoryId;
  final String lessonId;
  final String symbol;
  final String fallbackText;
  final String? assetKey;
  final String locale;
  final double rate;
  final double pitch;
}

class AudioCue {
  const AudioCue({
    required this.type,
    required this.assetKey,
    this.fallbackText,
    this.locale = 'ko-KR',
    this.rate = 0.46,
    this.pitch = 1.0,
  });

  final AudioCueType type;
  final String assetKey;
  final String? fallbackText;
  final String locale;
  final double rate;
  final double pitch;
}
