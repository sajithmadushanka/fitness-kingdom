import 'package:hive/hive.dart';
import 'package:fitness_kingdom/models/workout_set_data.dart';

part 'workout_exercise_data.g.dart';

@HiveType(typeId: 4) // Unique Type ID for Hive
class WorkoutExerciseData {
  @HiveField(0)
  final String exerciseId; // The ID of the ExerciseModel from the template
  @HiveField(1)
  final String exerciseName; // The name of the exercise (for display without looking up template)
  @HiveField(2)
  final List<WorkoutSetData> sets; // The list of performed sets for this exercise

  WorkoutExerciseData({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });
}