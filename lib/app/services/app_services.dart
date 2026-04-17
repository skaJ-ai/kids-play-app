import 'package:flutter/widgets.dart';

import '../audio/audio_service.dart';
import 'progress_store.dart';
import 'speech_cue_service.dart';

class AppServices {
  AppServices({
    required this.progressStore,
    SpeechCueService? speechCueService,
    AudioService? audioService,
  }) : speechCueService = speechCueService ?? NoopSpeechCueService(),
       audioService =
           audioService ??
           FallbackAudioService(
             speechCueService: speechCueService ?? NoopSpeechCueService(),
           );

  factory AppServices.fallback() {
    return AppServices(progressStore: MemoryProgressStore());
  }

  final ProgressStore progressStore;
  final SpeechCueService speechCueService;
  final AudioService audioService;
}

class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppServicesScope>();
    return scope?.services ?? AppServices.fallback();
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) {
    return oldWidget.services != services;
  }
}
