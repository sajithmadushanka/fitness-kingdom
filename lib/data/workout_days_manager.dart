import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WorkoutDaysManager {
  static const String _boxName = 'workout_days';

  static final WorkoutDaysManager _instance = WorkoutDaysManager._internal();
  factory WorkoutDaysManager() => _instance;

  WorkoutDaysManager._internal();

  late Box workoutDaysBox;

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      workoutDaysBox = await Hive.openBox<bool>(_boxName);
      _initialized = true;
    }
  }

  Future<void> saveWorkoutDay() async {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (!workoutDaysBox.containsKey(todayKey)) {
      await workoutDaysBox.put(todayKey, true);
      debugPrint('Workout day saved for $todayKey');
    } else {
      debugPrint('Workout already counted for $todayKey');
    }
  }

  Future<int> getWorkoutDaysThisWeek() async {
    if (!_initialized) {
      throw Exception('WorkoutDaysManager is not initialized. Call init() first.');
    }

    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 6));

    return workoutDaysBox.keys.where((key) {
      try {
        final date = DateTime.parse(key);
        return date.isAfter(weekAgo.subtract(const Duration(days: 1))) &&
               date.isBefore(now.add(const Duration(days: 1)));
      } catch (e) {
        debugPrint('Invalid date key in box: $key');
        return false;
      }
    }).length;
  }
}
