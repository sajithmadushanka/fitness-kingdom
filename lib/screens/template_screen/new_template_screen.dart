import 'package:fitness_kingdom/data/load_exercise.dart';
import 'package:fitness_kingdom/dialogs/workout_temp_dialog.dart'
    hide loadExercises;
import 'package:fitness_kingdom/models/exercise.dart';
import 'package:fitness_kingdom/models/workout_template.dart';
import 'package:fitness_kingdom/widgets/save_dance_btn.dart';
import 'package:flutter/material.dart';
import 'package:fitness_kingdom/data/workout_template_manager.dart'; // Import the manager

class NewTemplateScreen extends StatefulWidget {
  final WorkoutTemplate? template;
  const NewTemplateScreen({super.key, this.template});

  @override
  State<NewTemplateScreen> createState() => _NewTemplateScreenState();
}

class _NewTemplateScreenState extends State<NewTemplateScreen> {
  late TextEditingController _templateNameController;
  // No longer directly managing _isAddedExercise here,
  // its state will be derived from selected exercises.
  // bool _isAddedExercise = false;

  final WorkoutTemplateManager _workoutManager = WorkoutTemplateManager();

  @override
  void initState() {
    super.initState();
    _templateNameController = TextEditingController(
      text: widget.template?.name ?? '',
    );
    _workoutManager.selectedExercisesNotifier.value = widget.template?.exercises ?? [];
  }

  @override
  void dispose() {
    _templateNameController.dispose();
    // Don't dispose _workoutManager here as it's a singleton
    // and its ValueNotifier will be disposed by the manager itself,
    // usually on app shutdown or if explicitly called.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTemplateNameField(),
                      const SizedBox(height: 32),
                      _buildAddExerciseButton(context),
                      const SizedBox(height: 16),
                      // Listen to changes in selectedExercisesNotifier
                      ValueListenableBuilder<List<ExerciseModel>>(
                        valueListenable:
                            _workoutManager.selectedExercisesNotifier,
                        builder: (context, selectedExercises, child) {
                          return _buildExerciseList(selectedExercises);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildBackButton(context),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'New Template',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Update SaveButton to listen to the ValueNotifier
        ValueListenableBuilder<List<ExerciseModel>>(
          valueListenable: _workoutManager.selectedExercisesNotifier,
          builder: (context, selectedExercises, child) {
            print("el$selectedExercises");

            return SaveButton(
              isAddedExercise: selectedExercises.isNotEmpty,
              exerciseModelList: selectedExercises,
              templateName: _templateNameController.text,
              templateId: widget.template?.id,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      onPressed: () => _showDiscardDialog(context),
      icon: const Icon(Icons.close),
      tooltip: 'Go back',
    );
  }

  Widget _buildTemplateNameField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: _templateNameController, // Assign controller
          decoration: InputDecoration(
            hintText: 'Template Name',
            hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            prefix: SizedBox(width: 8),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            filled: false,
          ),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          if (_templateNameController.text == "") {
            showDialog(
              context: context, // You need a BuildContext here
              builder: (BuildContext context) {
                return AlertDialog(
                  content: const Text("Template name must be required"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
            // Important: return here to prevent _onTap() from being called
            return;
          }
          _addExercise(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Exercise"),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primaryContainer, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildExerciseList(List<ExerciseModel> exercises) {
    if (exercises.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No exercises added yet',
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Important for nested list views
      physics:
          const NeverScrollableScrollPhysics(), // Important for nested list views
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Exercise Image/Placeholder
                if (exercise.image.isNotEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(exercise.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.grey[600],
                      size: 30,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.category,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _workoutManager.removeExercise(exercise);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('Are you sure you want to discard your changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _workoutManager
                    .clearAllExercises(); // Clear exercises if discarding
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back
              },
              child: const Text('Discard', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _addExercise(BuildContext context) async {
    final Set<String>? selectedExerciseKeys = await showDialog<Set<String>>(
      context: context,
      builder: (context) => WorkoutTemplateDialog(
        initialSelectedExerciseKeys: Set<String>.from(
          _workoutManager.selectedExercisesNotifier.value.map((e) => e.id),
        ),
      ),
    );

    if (selectedExerciseKeys != null && selectedExerciseKeys.isNotEmpty) {
      // Load all exercise data once to find the full ExerciseModel objects
      // ignore: use_build_context_synchronously
      final Map<String, ExerciseModel> allExerciseData = await loadExercises(
        context,
      );

      // Filter out exercises that are already selected and convert keys to ExerciseModel
      final List<ExerciseModel> newExercisesToAdd = [];
      for (String key in selectedExerciseKeys) {
        final exercise = allExerciseData[key];
        if (exercise != null) {
          // Check if this exercise is NOT already in our current selected list
          if (!_workoutManager.selectedExercisesNotifier.value.any(
            (e) => e.id == exercise.id,
          )) {
            newExercisesToAdd.add(exercise);
          }
        }
      }

      // Add new exercises to the manager
      for (var exercise in newExercisesToAdd) {
        await _workoutManager.addExercise(exercise);
      }
    }
  }
}
