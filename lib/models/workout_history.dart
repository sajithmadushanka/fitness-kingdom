import 'package:hive/hive.dart';
import 'package:fitness_kingdom/models/workout_exercise_data.dart';

part 'workout_history.g.dart';

@HiveType(typeId: 2) // Unique Type ID for Hive
class WorkoutHistory {
  @HiveField(0)
  final String id; // Unique ID for this workout session
  @HiveField(1)
  final String templateId; // ID of the template used
  @HiveField(2)
  final String templateName; // Name of the template used (for display)
  @HiveField(3)
  final DateTime workoutDate;
  @HiveField(4)
  final int durationInMinutes; // Total duration of the workout
  @HiveField(5)
  final List<WorkoutExerciseData> exercisesPerformed; // List of exercises with their performed sets

  WorkoutHistory({
    required this.id,
    required this.templateId,
    required this.templateName,
    required this.workoutDate,
    required this.durationInMinutes,
    required this.exercisesPerformed,
  });
}