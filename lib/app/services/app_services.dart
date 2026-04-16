import 'package:flutter/widgets.dart';

import 'progress_store.dart';
import 'speech_cue_service.dart';

class AppServices {
  AppServices({
    required this.progressStore,
    required this.speechCueService,
  });

  factory AppServices.fallback() {
    return AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: NoopSpeechCueService(),
    );
  }

  final ProgressStore progressStore;
  final SpeechCueService speechCueService;
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
