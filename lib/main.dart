import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/services/app_services.dart';
import 'app/services/progress_store.dart';
import 'app/services/speech_cue_service.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final preferences = await SharedPreferences.getInstance();
  final services = AppServices(
    progressStore: SharedPreferencesProgressStore(preferences),
    speechCueService: FlutterTtsSpeechCueService(FlutterTts()),
  );

  runApp(KidsPlayApp(services: services));
}
