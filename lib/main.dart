// main.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/app.dart';
import 'package:fitness_kingdom/data/workout_template_manager.dart'; // Or your WorkoutTemplateRepository
import 'package:fitness_kingdom/data/workout_history_manager.dart'; // NEW
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fitness_kingdom/models/workout_template.dart';
import 'package:fitness_kingdom/models/exercise.dart';
import 'package:fitness_kingdom/models/workout_history.dart'; // NEW
import 'package:fitness_kingdom/models/workout_exercise_data.dart'; // NEW
import 'package:fitness_kingdom/models/workout_set_data.dart'; // NEW


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register Hive Adapters for your models
  Hive.registerAdapter(WorkoutTemplateAdapter());
  Hive.registerAdapter(ExerciseModelAdapter());
  Hive.registerAdapter(WorkoutHistoryAdapter());      // NEW
  Hive.registerAdapter(WorkoutExerciseDataAdapter()); // NEW
  Hive.registerAdapter(WorkoutSetDataAdapter());      // NEW

  // Initialize WorkoutTemplateManager (for saving templates)
  await WorkoutTemplateManager().init(); // Assuming this is your template save manager
  await WorkoutHistoryManager().init(); // NEW: Initialize history manager

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US')],
      path: 'assets/langs',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp()
    ),
  );
}