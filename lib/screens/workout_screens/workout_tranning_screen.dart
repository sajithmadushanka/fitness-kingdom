import 'package:fitness_kingdom/data/workout_template_manager.dart';
import 'package:fitness_kingdom/dialogs/workout_temp_dialog.dart';
import 'package:fitness_kingdom/shared/snak_bar.dart';
import 'package:fitness_kingdom/shared/workout_timer.dart';
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

  TrackedExercise({required this.id, required this.name, required this.sets});
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
  }) : weightController = TextEditingController(
         text: weight == 0.0 ? '' : weight.toStringAsFixed(0),
       ), // Start with empty string if 0
       repsController = TextEditingController(
         text: reps == 0 ? '' : reps.toString(),
       ); // Start with empty string if 0

  // Dispose controllers
  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class WorkoutTrackingScreen extends StatefulWidget {
  // Make the workoutTemplate parameter nullable
  final WorkoutTemplate? workoutTemplate;
  const WorkoutTrackingScreen({super.key, this.workoutTemplate});

  @override
  State<WorkoutTrackingScreen> createState() => _WorkoutTrackingScreenState();
}

class _WorkoutTrackingScreenState extends State<WorkoutTrackingScreen> {
  List<TrackedExercise> currentWorkoutExercises = [];
  late final WorkoutHistoryManager _workoutHistoryManager;

  // This will hold our working template, whether it's new or existing.
  late WorkoutTemplate _currentWorkoutTemplate;
  bool _isNewWorkout = false;

  final GlobalKey<WorkoutTimerState> _timerKey = GlobalKey<WorkoutTimerState>();
  Duration _finalWorkoutDuration = Duration.zero;
  void _handleDurationUpdate(Duration duration) {
    _finalWorkoutDuration = duration;
  }

  final WorkoutTemplateManager _workoutManager = WorkoutTemplateManager();

  @override
  void initState() {
    super.initState();
    _workoutHistoryManager = WorkoutHistoryManager();

    // Check if a template was passed in.
    if (widget.workoutTemplate == null) {
      _isNewWorkout = true;
      // Create a brand new, empty workout template.
      _currentWorkoutTemplate = WorkoutTemplate(
        id: const Uuid().v4(),
        name: '', // The name will be set by the user later.
        exercises: [],
        creationDate: DateTime.now(),
      );
    } else {
      _currentWorkoutTemplate = widget.workoutTemplate!;
    }
    // Initialize the tracked exercises based on the current template.
    _initializeWorkoutExercises();
  }

  @override
  void dispose() {
    for (var exercise in currentWorkoutExercises) {
      for (var set in exercise.sets) {
        set.dispose();
      }
    }
    super.dispose();
  }

  // This method now uses the private _currentWorkoutTemplate
  void _initializeWorkoutExercises() {
    currentWorkoutExercises.clear(); // Clear existing exercises on reset
    for (var exerciseTemplate in _currentWorkoutTemplate.exercises) {
      final List<WorkoutSetData> previousSets = _workoutHistoryManager
          .getLastPerformedSetsForExercise(exerciseTemplate.id);

      List<TrackedSet> initialSets = [];
      if (previousSets.isNotEmpty) {
        for (var ps in previousSets) {
          initialSets.add(
            TrackedSet(previousWeight: ps.weight, previousReps: ps.reps),
          );
        }
      } else {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Minimize Handle
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
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
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.refresh,
                        size: 20,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),

                  // Finish Button
                  ElevatedButton(
                    onPressed: () {
                      _showFinishDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Finish',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
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
                          // Use the current workout template name
                          _currentWorkoutTemplate.name.isNotEmpty
                              ? _currentWorkoutTemplate.name
                              : 'New Workout',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // More options button for workout (not implemented yet)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.more_horiz,
                          size: 20,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  WorkoutTimer(
                    key: _timerKey,
                    onDurationUpdated: _handleDurationUpdate,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Notes', // This could be dynamic from template notes if you add them
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Exercise List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: currentWorkoutExercises.length,
                itemBuilder: (context, index) {
                  return _buildExerciseCard(
                    currentWorkoutExercises[index],
                    index,
                  );
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
                        _addExercise(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: colorScheme.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: colorScheme.onSurface,
                      ),
                      child: Text(
                        'Add Exercise',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: colorScheme.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: colorScheme.error,
                      ),
                      child: Text(
                        'Cancel Workout',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
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
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.show_chart, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      _showDeleteExerciseDialog(context, exercise);
                    },
                    icon: Icon(
                      Icons.more_horiz,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sets Header
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      'Set',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Previous',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      'kg',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Reps',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 12),

              // Sets List
              ...exercise.sets.asMap().entries.map((entry) {
                int setIndex = entry.key;
                TrackedSet set = entry.value;
                return _buildSetRow(exerciseIndex, setIndex, set);
              }),

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
                          previousWeight: exercise.sets.isNotEmpty
                              ? exercise.sets.last.previousWeight
                              : null,
                          previousReps: exercise.sets.isNotEmpty
                              ? exercise.sets.last.previousReps
                              : null,
                        ),
                      );
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: colorScheme.outline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: colorScheme.onSurface,
                  ),
                  child: Text(
                    '+ Add Set',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, TrackedSet set) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              // Set Number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${setIndex + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSecondaryContainer,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Weight Input
              Container(
                width: 60,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: set.weightController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ), // Allow decimals
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: set.previousWeight != null
                        ? set.previousWeight!.toStringAsFixed(0)
                        : '', // Hint
                    hintStyle: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onChanged: (value) {
                    // Update the model and controller
                    set.weight = double.tryParse(value) ?? 0.0;
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Reps Input
              Container(
                width: 60,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextField(
                  controller: set.repsController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: set.previousReps != null
                        ? set.previousReps!.toString()
                        : '', // Hint
                    hintStyle: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
                    if (set.isCompleted &&
                        set.previousWeight != null &&
                        set.previousReps != null) {
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
                    color: set.isCompleted
                        ? colorScheme.primary
                        : colorScheme.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: set.isCompleted
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFinishDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // New logic for a new workout
    if (_isNewWorkout) {
      final nameController = TextEditingController();
      final templateName = await showDialog<String?>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            'Save Workout as Template?',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter a name for this new workout template:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Full Body Blast',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null); // Don't save as template
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
              child: const Text('Don\'t Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, nameController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      // Handle the user's response from the dialog
      if (templateName != null) {
        // If the user provided a name (or a blank one)
        _currentWorkoutTemplate.name = templateName.isNotEmpty
            ? templateName
            : 'Custom Workout - ${DateTime.now().month}/${DateTime.now().day}';

        // Save the new template
        await _workoutManager.saveOrUpdateWorkoutTemplate(
          _currentWorkoutTemplate,
        );
      } else {
        // User chose "Don't Save" or closed the dialog
        // We will still save the history, but not the template
        if (context.mounted) {
          showSnackBar('Workout will not be saved as a template.', context);
        }
      }
    } else {
      // For existing workouts, just update the last workout date
      WorkoutTemplateManager().lastWorkoutDateUpdate(
        _currentWorkoutTemplate.id,
        DateTime.now(),
      );
    }

    // The rest of the logic remains the same for saving workout history
    _saveWorkoutHistory();
  }

  void _saveWorkoutHistory() async {
    final finalDuration =
        _timerKey.currentState?.getDuration() ?? Duration.zero;
    // Prepare data for WorkoutHistory
    List<WorkoutExerciseData> exercisesToSave = [];
    for (var trackedExercise in currentWorkoutExercises) {
      List<WorkoutSetData> setsToSave = [];
      for (var trackedSet in trackedExercise.sets) {
        // Only save sets that were marked as completed AND have data entered
        if (trackedSet.isCompleted &&
            (trackedSet.weight > 0 || trackedSet.reps > 0)) {
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
        templateId: _currentWorkoutTemplate.id,
        templateName: _currentWorkoutTemplate.name,
        workoutDate: DateTime.now(),
        durationInMinutes: finalDuration.inMinutes,
        exercisesPerformed: exercisesToSave,
      );

   
      // Save to Hive
      try {
        await _workoutHistoryManager.addWorkoutHistory(newHistory);
        if (mounted) {
          showSnackBar('Workout saved to history!', context, isSuccess: true);
        }
      } catch (e) {
        debugPrint('Error saving workout history: $e');
        if (mounted) {
          showSnackBar('Failed to save workout: ${e.toString()}', context);
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
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Workout'),
        content: const Text(
          'Are you sure you want to cancel this workout? All progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Going'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
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
        content: const Text(
          'Are you sure you want to reset all current progress in this workout?',
        ),
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
                _timerKey.currentState?.reset();
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

  void _addExercise(BuildContext context) async {
    final Set<String>? selectedExerciseKeys = await showDialog<Set<String>>(
      context: context,
      builder: (context) => WorkoutTemplateDialog(),
    );

    if (selectedExerciseKeys != null && selectedExerciseKeys.isNotEmpty) {
      final Map<String, ExerciseModel> allExerciseData = await loadExercises(
        // ignore: use_build_context_synchronously
        context,
      );

      final List<ExerciseModel> newExercisesToAdd = [];
      for (String key in selectedExerciseKeys) {
        final exercise = allExerciseData[key];
        if (exercise != null) {
          // Check if this exercise is NOT already in our current selected list
          if (!_currentWorkoutTemplate.exercises.any(
            (e) => e.id == exercise.id,
          )) {
            newExercisesToAdd.add(exercise);
          }
        }
      }

      if (newExercisesToAdd.isNotEmpty) {
        // Add the new exercises to the workoutTemplate's list of exercises
        _currentWorkoutTemplate.exercises.addAll(newExercisesToAdd);

        // Update the Hive box with the modified workout template
        await _workoutManager.saveOrUpdateWorkoutTemplate(
          _currentWorkoutTemplate,
        );

        // Re-initialize the current workout exercises to include the new ones
        setState(() {
          _initializeWorkoutExercises();
        });
      }
    }
  }

  void _showDeleteExerciseDialog(
    BuildContext context,
    TrackedExercise exercise,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Exercise"),
          content: Text(
            "Do you want to delete '${exercise.name}' from this workout template? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog

                // 1. Remove the exercise from the local list
                setState(() {
                  currentWorkoutExercises.removeWhere(
                    (e) => e.id == exercise.id,
                  );
                });

                // 2. Remove the exercise from the workout template model
                _currentWorkoutTemplate.exercises.removeWhere(
                  (e) => e.id == exercise.id,
                );

                // 3. Save the updated template to Hive
                await _workoutManager.saveOrUpdateWorkoutTemplate(
                  _currentWorkoutTemplate,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("'${exercise.name}' deleted from workout."),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
