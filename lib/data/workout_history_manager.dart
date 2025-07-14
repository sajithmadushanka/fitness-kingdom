// data/workout_history_manager.dart
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitness_kingdom/models/workout_history.dart';
import 'package:fitness_kingdom/models/workout_exercise_data.dart';
import 'package:fitness_kingdom/models/workout_set_data.dart';

class WorkoutHistoryManager {
  static const String _boxName = 'workoutHistoryBox';

  late Box<WorkoutHistory> _workoutHistoryBox;

  // Private constructor
  WorkoutHistoryManager._privateConstructor();

  // Singleton instance
  static final WorkoutHistoryManager _instance =
      WorkoutHistoryManager._privateConstructor();

  // Factory constructor to return the singleton instance
  factory WorkoutHistoryManager() {
    return _instance;
  }

  // Initialize Hive box
  Future<void> init() async {
    // Ensure all nested adapters are registered
    if (!Hive.isAdapterRegistered(WorkoutHistoryAdapter().typeId)) {
      Hive.registerAdapter(WorkoutHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkoutExerciseDataAdapter().typeId)) {
      Hive.registerAdapter(WorkoutExerciseDataAdapter());
    }
    if (!Hive.isAdapterRegistered(WorkoutSetDataAdapter().typeId)) {
      Hive.registerAdapter(WorkoutSetDataAdapter());
    }

    _workoutHistoryBox = await Hive.openBox<WorkoutHistory>(_boxName);
    print(
      'WorkoutHistoryManager initialized. Box open: ${_workoutHistoryBox.isOpen}',
    );
  }

  // Save a new workout history record
  Future<void> addWorkoutHistory(WorkoutHistory history) async {
    await _workoutHistoryBox.put(history.id, history);
    print('Workout History for "${history.templateName}" saved successfully!');
    for (var i in history.exercisesPerformed) {
          i.sets.forEach((j)=>{
            print(j.weight),
            print(j.reps)
          });
    }
  }

  // Get all workout history records
  List<WorkoutHistory> getAllWorkoutHistory() {
    return _workoutHistoryBox.values.toList();
  }

  // NEW METHOD: Get the list of WorkoutSetData for an exercise from its most recent history
  List<WorkoutSetData> getLastPerformedSetsForExercise(String exerciseId) {
    // Find all history entries that contain this exercise
    final relevantHistory = _workoutHistoryBox.values
        .where(
          (history) =>
              history.exercisesPerformed.any((e) => e.exerciseId == exerciseId),
        )
        .toList();

    if (relevantHistory.isEmpty) {
      return []; // No history for this exercise
    }

    // Sort by workout date to get the most recent one first
    relevantHistory.sort((a, b) => b.workoutDate.compareTo(a.workoutDate));

    // Find the exercise data within the most recent history entry
    final latestHistoryEntry = relevantHistory.first;
    final WorkoutExerciseData?
    exerciseData = latestHistoryEntry.exercisesPerformed.firstWhereOrNull(
      (e) => e.exerciseId == exerciseId,
    ); // Using firstWhereOrNull (needs 'package:collection/collection.dart') or manual check

    if (exerciseData != null) {
      return exerciseData.sets;
    }
    return []; // Exercise not found in the latest history entry (shouldn't happen if filtered correctly)
  }

  // You can keep the getMaxCommitForExercise if you want to use it elsewhere,
  // but for the "Previous" display in this screen, we'll use getLastPerformedSetsForExercise.
  double getMaxCommitForExercise(String exerciseId) {
    double maxCommit = 0.0;
    final relevantHistory = _workoutHistoryBox.values
        .where(
          (history) =>
              history.exercisesPerformed.any((e) => e.exerciseId == exerciseId),
        )
        .toList();

    for (var history in relevantHistory) {
      for (var exerciseData in history.exercisesPerformed) {
        if (exerciseData.exerciseId == exerciseId) {
          for (var setData in exerciseData.sets) {
            if (setData.isCompleted) {
              double currentCommit = setData.weight * setData.reps;
              if (currentCommit > maxCommit) {
                maxCommit = currentCommit;
              }
            }
          }
        }
      }
    }
    return maxCommit;
  }

  // Dispose the Hive box
  void dispose() {
    _workoutHistoryBox.close();
  }
}

// Add this extension if you don't have it, or import 'package:collection/collection.dart';
extension IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
