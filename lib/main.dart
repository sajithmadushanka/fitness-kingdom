import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/app.dart';
import 'package:fitness_kingdom/data/workout_template_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
    // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Initialize WorkoutTemplateManager (which also opens the Hive box and loads data)
  await WorkoutTemplateManager().init();
  
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US')],
      path: 'assets/langs', 
      fallbackLocale: Locale('en', 'US'),
      child: MyApp()
    ),
  );
}