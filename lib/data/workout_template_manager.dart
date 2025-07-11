import 'package:fitness_kingdom/models/workout_template.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitness_kingdom/models/exercise.dart'; // Make sure this path is correct

class WorkoutTemplateManager {
  // static const String _boxName = 'workoutTemplatesBox';
  // static const String _keySelectedExercises = 'selectedExercises';

  // ValueNotifier to hold the list of selected exercises
  final ValueNotifier<List<ExerciseModel>> selectedExercisesNotifier =
      ValueNotifier<List<ExerciseModel>>([]);

  // late Box<List<dynamic>> _workoutBox;

  // Private constructor
  WorkoutTemplateManager._privateConstructor();

  // Singleton instance
  static final WorkoutTemplateManager _instance =
      WorkoutTemplateManager._privateConstructor();

  // Factory constructor to return the singleton instance
  factory WorkoutTemplateManager() {
    return _instance;
  }

  // Initialize Hive box
 Future<void> init() async {
  if (!Hive.isAdapterRegistered(ExerciseModelAdapter().typeId)) {
    Hive.registerAdapter(ExerciseModelAdapter());
  }

  if (!Hive.isAdapterRegistered(WorkoutTemplateAdapter().typeId)) {
  Hive.registerAdapter(WorkoutTemplateAdapter());
}


// await Hive.deleteBoxFromDisk('workoutTemplatesBox'); // Clears incorrect data
await Hive.openBox<WorkoutTemplate>('workoutTemplatesBox'); // Reopen correctly
}


Future<void> saveWorkoutTemplate(WorkoutTemplate template) async {
  final box = Hive.box<WorkoutTemplate>('workoutTemplatesBox');
  await box.put(template.id, template);
  print("template save success ${template.id}");
}

Future<List<WorkoutTemplate>> getAllTemplates() async {
  final box = Hive.box<WorkoutTemplate>('workoutTemplatesBox');
  return box.values.map((e) => e).toList();
}


Future<void> deleteTemplate(String id) async {
  final box = Hive.box<WorkoutTemplate>('workoutTemplatesBox');
  await box.delete(id);
}

  // Load exercises from Hive into the ValueNotifier
  // void _loadExercises() {
  //   final List<dynamic>? storedExercises = _workoutBox.get(_keySelectedExercises);
  //   if (storedExercises != null) {
  //     selectedExercisesNotifier.value =
  //         storedExercises.cast<ExerciseModel>(); // Cast to the correct type
  //   } else {
  //     selectedExercisesNotifier.value = [];
  //   }
  // }

  // Add an exercise to the selected list and persist
  Future<void> addExercise(ExerciseModel exercise) async {
    final currentList = List<ExerciseModel>.from(selectedExercisesNotifier.value);
    if (!currentList.any((e) => e.id == exercise.id)) { // Prevent duplicates based on ID
      currentList.add(exercise);
      selectedExercisesNotifier.value = currentList;
      // await _workoutBox.put(_keySelectedExercises, currentList);
    }
  }

  // Remove an exercise from the selected list and persist
  Future<void> removeExercise(ExerciseModel exercise) async {
    final currentList = List<ExerciseModel>.from(selectedExercisesNotifier.value);
    currentList.removeWhere((e) => e.id == exercise.id);
    selectedExercisesNotifier.value = currentList;
    // await _workoutBox.put(_keySelectedExercises, currentList);
  }

  // Clear all selected exercises and persist
  Future<void> clearAllExercises() async {
    selectedExercisesNotifier.value = [];
    // await _workoutBox.put(_keySelectedExercises, []);
  }

  // Dispose the ValueNotifier when no longer needed
  void dispose() {
    selectedExercisesNotifier.dispose();
  }
}