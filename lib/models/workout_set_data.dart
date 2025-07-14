import 'package:hive/hive.dart';

part 'workout_set_data.g.dart';

@HiveType(typeId: 3) // Unique Type ID for Hive
class WorkoutSetData {
  @HiveField(0)
  final double weight; // Use double for weight to allow decimal values
  @HiveField(1)
  final int reps;
  @HiveField(2)
  final bool isCompleted; // To save if the set was marked completed

  WorkoutSetData({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });

  // Optional: A method to calculate "volume" or "commit" for this set
  double get commit => weight * reps;
}