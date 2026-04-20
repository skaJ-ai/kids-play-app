import 'package:flutter/widgets.dart';
import 'package:kids_play_app/features/avatar/application/avatar_photo_picker.dart';
import 'package:kids_play_app/features/avatar/application/avatar_photo_service.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';

import '../audio/audio_service.dart';
import '../audio/tts_fallback_audio_service.dart';
import 'progress_store.dart';
import 'speech_cue_service.dart';

class AppServices {
  factory AppServices({
    required ProgressStore progressStore,
    required SpeechCueService speechCueService,
    AudioService? audioService,
    AvatarPhotoStore? avatarPhotoStore,
    AvatarPhotoRepository? avatarPhotoRepository,
    AvatarPhotoService? avatarPhotoService,
    AvatarPhotoPicker? avatarPhotoPicker,
  }) {
    final resolvedAvatarPhotoStore =
        avatarPhotoStore ?? _MemoryAvatarPhotoStore();
    final resolvedAvatarPhotoRepository =
        avatarPhotoRepository ?? const NoopAvatarPhotoRepository();

    return AppServices._(
      progressStore: progressStore,
      speechCueService: speechCueService,
      audioService:
          audioService ?? TtsFallbackAudioService(speech: speechCueService),
      avatarPhotoStore: resolvedAvatarPhotoStore,
      avatarPhotoRepository: resolvedAvatarPhotoRepository,
      avatarPhotoService:
          avatarPhotoService ??
          AvatarPhotoService(
            photoStore: resolvedAvatarPhotoStore,
            repository: resolvedAvatarPhotoRepository,
          ),
      avatarPhotoPicker: avatarPhotoPicker ?? const NoopAvatarPhotoPicker(),
    );
  }

  AppServices._({
    required this.progressStore,
    required this.speechCueService,
    required this.audioService,
    required this.avatarPhotoStore,
    required this.avatarPhotoRepository,
    required this.avatarPhotoService,
    required this.avatarPhotoPicker,
  });

  factory AppServices.fallback() {
    return AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: NoopSpeechCueService(),
    );
  }

  final ProgressStore progressStore;
  final SpeechCueService speechCueService;
  final AudioService audioService;
  final AvatarPhotoStore avatarPhotoStore;
  final AvatarPhotoRepository avatarPhotoRepository;
  final AvatarPhotoService avatarPhotoService;
  final AvatarPhotoPicker avatarPhotoPicker;
}

class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppServicesScope>();
    return scope?.services ?? AppServices.fallback();
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) {
    return oldWidget.services != services;
  }
}

class _MemoryAvatarPhotoStore implements AvatarPhotoStore {
  AvatarPhotoSnapshot _snapshot = const AvatarPhotoSnapshot();

  @override
  Future<AvatarPhotoSnapshot> loadSnapshot() async => _snapshot;

  @override
  Future<void> saveSnapshot(AvatarPhotoSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}
