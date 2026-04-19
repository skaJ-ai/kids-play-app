import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/audio/tts_fallback_audio_service.dart';
import 'app/services/app_services.dart';
import 'app/services/progress_store.dart';
import 'app/services/speech_cue_service.dart';
import 'features/avatar/application/avatar_photo_service.dart';
import 'features/avatar/data/avatar_photo_store.dart';
import 'features/avatar/data/local_avatar_photo_repository.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final preferences = await SharedPreferences.getInstance();
  final speech = FlutterTtsSpeechCueService(FlutterTts());
  final avatarPhotoStore = AvatarPhotoStore(preferences);
  final avatarPhotoRepository = LocalAvatarPhotoRepository(
    getApplicationSupportDirectory,
  );
  final avatarPhotoService = AvatarPhotoService(
    photoStore: avatarPhotoStore,
    repository: avatarPhotoRepository,
  );
  final services = AppServices(
    progressStore: SharedPreferencesProgressStore(preferences),
    speechCueService: speech,
    audioService: TtsFallbackAudioService(speech: speech),
    avatarPhotoStore: avatarPhotoStore,
    avatarPhotoRepository: avatarPhotoRepository,
    avatarPhotoService: avatarPhotoService,
  );

  runApp(KidsPlayApp(services: services));
}
