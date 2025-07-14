import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:fitness_kingdom/models/workout_template.dart';
import 'package:fitness_kingdom/models/exercise.dart';
import 'package:fitness_kingdom/models/workout_history.dart';
import 'package:fitness_kingdom/models/workout_exercise_data.dart';
import 'package:fitness_kingdom/models/workout_set_data.dart';
import 'package:fitness_kingdom/data/workout_history_manager.dart';

// Local class to hold the mutable state of an exercise during tracking
class TrackedExercise {
  final String id; // Corresponds to ExerciseModel.id
  final String name; // Corresponds to ExerciseModel.name
  List<TrackedSet> sets; // List of sets being performed

  TrackedExercise({
    required this.id,
    required this.name,
    required this.sets,
  });
}

// Local class to hold the mutable state of a set during tracking
class TrackedSet {
  double weight;
  int reps;
  double? previousWeight; // Stored previous weight
  int? previousReps; // Stored previous reps
  bool isCompleted;

  // TextEditingControllers for the input fields
  final TextEditingController weightController;
  final TextEditingController repsController;

  TrackedSet({
    this.weight = 0.0,
    this.reps = 0,
    this.previousWeight,
    this.previousReps,
    this.isCompleted = false,
  }) :  weightController = TextEditingController(text: weight == 0.0 ? '' : weight.toStringAsFixed(0)), // Start with empty string if 0
        repsController = TextEditingController(text: reps == 0 ? '' : reps.toString()); // Start with empty string if 0

  // Dispose controllers
  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}


class WorkoutTrackingScreen extends StatefulWidget {
  final WorkoutTemplate workoutTemplate;
  const WorkoutTrackingScreen({super.key, required this.workoutTemplate});

  @override
  State<WorkoutTrackingScreen> createState() => _WorkoutTrackingScreenState();
}

class _WorkoutTrackingScreenState extends State<WorkoutTrackingScreen> {
  late List<TrackedExercise> currentWorkoutExercises;
  late final WorkoutHistoryManager _workoutHistoryManager;

  late Timer _timer;
  Duration _workoutDuration = Duration.zero;
  // bool _isWorkoutActive = false; // Not strictly needed as timer presence implies active

  @override
  void initState() {
    super.initState();
    _workoutHistoryManager = WorkoutHistoryManager();
    _initializeWorkoutExercises();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop the timer
    // Dispose all TextEditingControllers
    for (var exercise in currentWorkoutExercises) {
      for (var set in exercise.sets) {
        set.dispose();
      }
    }
    super.dispose();
  }

  void _initializeWorkoutExercises() {
    currentWorkoutExercises = [];
    for (var exerciseTemplate in widget.workoutTemplate.exercises) {
      final List<WorkoutSetData> previousSets =
          _workoutHistoryManager.getLastPerformedSetsForExercise(exerciseTemplate.id);

      List<TrackedSet> initialSets = [];
      if (previousSets.isNotEmpty) {
        // If there's previous history, populate with those sets
        for (var ps in previousSets) {
          initialSets.add(TrackedSet(
            previousWeight: ps.weight,
            previousReps: ps.reps,
            // Keep current weight/reps as 0 initially
          ));
        }
      } else {
        // If no previous history, start with one empty set
        initialSets.add(TrackedSet());
      }

      currentWorkoutExercises.add(
        TrackedExercise(
          id: exerciseTemplate.id,
          name: exerciseTemplate.name,
          sets: initialSets,
        ),
      );
    }
  }

  void _startTimer() {
    // _isWorkoutActive = true; // No longer needed
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _workoutDuration += const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Minimize Handle
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button (or Reset workout)
                  GestureDetector(
                    onTap: () {
                      _showResetDialog(context); // Show dialog before resetting
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // Finish Button
                  ElevatedButton(
                    onPressed: () {
                      _showFinishDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Finish',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Workout Title and Timer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.workoutTemplate.name, // Display workout template name
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // More options button for workout (not implemented yet)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.more_horiz,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(_workoutDuration), // Display live timer
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Notes', // This could be dynamic from template notes if you add them
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Exercise List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: currentWorkoutExercises.length,
                itemBuilder: (context, index) {
                  return _buildExerciseCard(currentWorkoutExercises[index], index);
                },
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement actual Add Exercise logic
                        _showAddExerciseDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Add Exercise',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showCancelDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel Workout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(TrackedExercise exercise, int exerciseIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Icon(
                Icons.show_chart,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              // More options for individual exercise (not implemented yet)
              const Icon(
                Icons.more_horiz,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sets Header
          Row(
            children: [
              const SizedBox(width: 40, child: Text('Set', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              const SizedBox(width: 16),
              const Expanded(child: Text('Previous', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              const SizedBox(width: 60, child: Text('kg', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              const SizedBox(width: 16),
              const SizedBox(width: 60, child: Text('Reps', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              const SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 12),

          // Sets List
          ...exercise.sets.asMap().entries.map((entry) {
            int setIndex = entry.key;
            TrackedSet set = entry.value;
            return _buildSetRow(exerciseIndex, setIndex, set);
          }).toList(),

          // Add Set Button
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  // Add a new empty set, carrying over the previous best values if available
                  currentWorkoutExercises[exerciseIndex].sets.add(
                    TrackedSet(
                      previousWeight: exercise.sets.isNotEmpty ? exercise.sets.last.previousWeight : null,
                      previousReps: exercise.sets.isNotEmpty ? exercise.sets.last.previousReps : null,
                    ),
                  );
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Add Set',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, TrackedSet set) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Set Number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${setIndex + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Previous (Weight x Reps from History)
          Expanded(
            child: Text(
              set.previousWeight != null && set.previousReps != null
                  ? '${set.previousWeight!.toStringAsFixed(0)}kg x ${set.previousReps}'
                  : '-',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          // Weight Input
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: set.weightController,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true), // Allow decimals
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: set.previousWeight != null ? set.previousWeight!.toStringAsFixed(0) : '', // Hint
              ),
              onChanged: (value) {
                // Update the model and controller
                set.weight = double.tryParse(value) ?? 0.0;
                // No setState here, as controller update handles it, and we might not need immediate UI refresh for every char
                // The main setState will happen when the checkbox is toggled or a set is added/removed.
              },
            ),
          ),

          const SizedBox(width: 16),

          // Reps Input
          Container(
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: set.repsController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: set.previousReps != null ? set.previousReps!.toString() : '', // Hint
              ),
              onChanged: (value) {
                // Update the model and controller
                set.reps = int.tryParse(value) ?? 0;
              },
            ),
          ),

          const SizedBox(width: 16),

          // Check Button (Toggle completion and populate if previous exists)
          GestureDetector(
            onTap: () {
              setState(() {
                set.isCompleted = !set.isCompleted;
                if (set.isCompleted && set.previousWeight != null && set.previousReps != null) {
                  // If checkbox is toggled ON and previous data exists,
                  // populate the current weight/reps with previous values
                  set.weight = set.previousWeight!;
                  set.reps = set.previousReps!;
                  set.weightController.text = set.weight.toStringAsFixed(0);
                  set.repsController.text = set.reps.toString();
                } else if (!set.isCompleted) {
                  // If checkbox is toggled OFF, clear the inputs (or reset to 0)
                  set.weight = 0.0;
                  set.reps = 0;
                  set.weightController.text = ''; // Clear text
                  set.repsController.text = ''; // Clear text
                }
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: set.isCompleted ? Colors.green : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: set.isCompleted ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFinishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Workout'),
        content: const Text('Are you sure you want to finish this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Stop the timer
              _timer.cancel();
              // _isWorkoutActive = false; // Not strictly needed

              // Prepare data for WorkoutHistory
              List<WorkoutExerciseData> exercisesToSave = [];
              for (var trackedExercise in currentWorkoutExercises) {
                List<WorkoutSetData> setsToSave = [];
                for (var trackedSet in trackedExercise.sets) {
                  // Only save sets that were marked as completed AND have data entered
                  if (trackedSet.isCompleted && (trackedSet.weight > 0 || trackedSet.reps > 0)) {
                    setsToSave.add(
                      WorkoutSetData(
                        weight: trackedSet.weight,
                        reps: trackedSet.reps,
                        isCompleted: trackedSet.isCompleted,
                      ),
                    );
                  }
                }
                // Only add exercises that have at least one valid completed set to save
                if (setsToSave.isNotEmpty) {
                  exercisesToSave.add(
                    WorkoutExerciseData(
                      exerciseId: trackedExercise.id,
                      exerciseName: trackedExercise.name,
                      sets: setsToSave,
                    ),
                  );
                }
              }

              // Create WorkoutHistory object
              if (exercisesToSave.isNotEmpty) {
                WorkoutHistory newHistory = WorkoutHistory(
                  id: const Uuid().v4(),
                  templateId: widget.workoutTemplate.id,
                  templateName: widget.workoutTemplate.name,
                  workoutDate: DateTime.now(),
                  durationInMinutes: _workoutDuration.inMinutes,
                  exercisesPerformed: exercisesToSave,
                );

                // Save to Hive
                try {
                  await _workoutHistoryManager.addWorkoutHistory(newHistory);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Workout saved to history!')),
                    );
                  }
                } catch (e) {
                  print('Error saving workout history: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save workout: ${e.toString()}')),
                    );
                  }
                }
              } else {
                 if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('No completed sets to save.')),
                   );
                 }
              }

              // Pop the WorkoutTrackingScreen
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Workout'),
        content: const Text('Are you sure you want to cancel this workout? All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Going'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _timer.cancel(); // Stop timer
              if (context.mounted) {
                Navigator.pop(context); // Pop WorkoutTrackingScreen
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Workout'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Workout'),
        content: const Text('Are you sure you want to reset all current progress in this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _initializeWorkoutExercises(); // Re-initialize all exercises to their fresh state
                _workoutDuration = Duration.zero; // Reset timer
                _timer.cancel(); // Cancel old timer
                _startTimer(); // Start new timer
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Workout progress reset.')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: const Text('Implement logic to select and add more exercises here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Example: Adding a hardcoded new exercise for demonstration
              setState(() {
                currentWorkoutExercises.add(
                  TrackedExercise(
                    id: const Uuid().v4(), // Give a unique ID for this session
                    name: 'New Custom Exercise',
                    sets: [TrackedSet()], // Start with one empty set
                  ),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Add Dummy Exercise'),
          ),
        ],
      ),
    );
  }
}