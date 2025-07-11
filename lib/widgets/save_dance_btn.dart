import 'package:fitness_kingdom/data/exercises.dart';
import 'package:fitness_kingdom/data/workout_template_manager.dart';
import 'package:fitness_kingdom/models/exercise.dart';
import 'package:fitness_kingdom/models/workout_template.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SaveButton extends StatefulWidget {
  final bool isAddedExercise;
  final List<ExerciseModel> exerciseModelList;
  final String templateName;
  const SaveButton({
    super.key,
    required this.isAddedExercise,
    required this.exerciseModelList,
    required this.templateName,
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.05, 0), // Move slightly to the right
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
  }

  void _onTap() async {
    if (widget.isAddedExercise) {
      WorkoutTemplate newWorkoutTemplate = WorkoutTemplate(
        id: Uuid().v4(),
        name: widget.templateName,
        exercises: widget.exerciseModelList,
        creationDate: DateTime.now(),
      );

      await WorkoutTemplateManager().saveWorkoutTemplate(newWorkoutTemplate);

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(); // Optionally close the dialog/screen
        // print("done");

      
      }
    } else {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isAddedExercise ? 1.0 : 0.4,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Slightly square
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _onTap,
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isAddedExercise ? Colors.white : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
