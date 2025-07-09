import 'package:fitness_kingdom/data/load_exercise.dart';
import 'package:fitness_kingdom/dialogs/workout_temp_dialog.dart';
import 'package:fitness_kingdom/models/exercise.dart';
import 'package:fitness_kingdom/widgets/save_dance_btn.dart';
import 'package:flutter/material.dart';

class NewTemplateScreen extends StatefulWidget {
  const NewTemplateScreen({super.key});

  @override
  State<NewTemplateScreen> createState() => _NewTemplateScreenState();
}

class _NewTemplateScreenState extends State<NewTemplateScreen> {
  final TextEditingController _templateNameController = TextEditingController();
  bool _isAddedExercise = false;

  @override
  void dispose() {
    _templateNameController.dispose();
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
                      _buildExerciseList(),
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
        SaveButton(isAddedExercise: _isAddedExercise),
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
    return // template name text field
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 40,
        child: TextField(
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _addExercise(context),
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

  Widget _buildExerciseList() {
    // Placeholder for exercise list
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
    setState(() {
      _isAddedExercise = true;
    });

    final Set<String>? selectedExercises = await showDialog<Set<String>>(
      context: context,
      builder: (context) => WorkoutTemplateDialog(),
    );

    if (selectedExercises != null && selectedExercises.isNotEmpty) {
      // Load the JSON data to get full exercise details
      final exerciseData = await loadExercises(context);

      // Access each selected exercise by key
      for (String exerciseKey in selectedExercises) {
        final ExerciseModel? exercise = exerciseData[exerciseKey];
        if (exercise != null) {
          print("id${exercise.id}");
          print('Exercise Name: ${exercise.name}');
          print('Category: ${exercise.category}');
          print('Instructions: ${exercise.instructions}');
          print('Image: ${exercise.image}');
        }
      }

      // _handleSelectedExercises(selectedExercises, exerciseData);
    }
  }

  void _handleSelectedExercises(Set<String> selectedExercises) {
    // Process the selected exercises here
    for (String exerciseKey in selectedExercises) {
      print('Selected exercise key: $exerciseKey');
      // Add to your workout list, save to database, etc.
    }

    setState(() {
      // Update your UI with the selected exercises
      // Example: _workoutExercises.addAll(selectedExercises);
    });
  }
}
