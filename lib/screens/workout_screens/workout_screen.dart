import 'package:fitness_kingdom/data/workout_template_manager.dart';
import 'package:fitness_kingdom/screens/template_screen/new_template_screen.dart';
import 'package:fitness_kingdom/screens/workout_screens/workout_tranning_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitness_kingdom/models/workout_template.dart'; // Import your WorkoutTemplate model
import 'package:hive_flutter/hive_flutter.dart'; // Import your ExerciseModel

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center(
            //   child: Text(
            //     'Workout',
            //     style: TextStyle(
            //       fontSize: 20,
            //       color: Colors.black,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),

            // Quick Start Section
            Text(
              'Quick Start',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutTrackingScreen(),
                            ),
                          );
                        },
                        child: const Text('Start Empty Workout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Templates Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Templates',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    WorkoutTemplateManager().clearAllExercises();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return NewTemplateScreen();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Template'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Templates Grid (using FutureBuilder to fetch data)
            // Templates Grid (listening to Hive updates)
            ValueListenableBuilder<Box<WorkoutTemplate>>(
              valueListenable: Hive.box<WorkoutTemplate>(
                'workoutTemplatesBox',
              ).listenable(),
              builder: (context, box, _) {
                final templates = box.values.toList();
                if (templates.isEmpty) {
                  return Center(
                    child: Text(
                      'No templates found. Create one!',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                } else {
                  return _buildTemplatesGrid(context, templates);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesGrid(
    BuildContext context,
    List<WorkoutTemplate> templates,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1, // Reduced height
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: colorScheme.shadow.withValues(alpha: 0.1),
            //     blurRadius: 6,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onLongPress: () => _deleteDialog(context, template),
              onTap: () => _showWorkoutTemplateDialog(context, template),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Dynamic icon based on template
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getTemplateIcon(template),
                            color: colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        // Exercise count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${template.exercises.length}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Template name
                    Text(
                      template.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Exercise details
                    Text(
                      _getExercisesSummary(template),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Last workout indicator
                    Row(
                      children: [
                        Icon(
                          template.lastWorkoutDate != null
                              ? Icons.access_time_rounded
                              : Icons.play_arrow_rounded,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            template.lastWorkoutDate != null
                                ? _formatLastWorkoutDate(
                                    template.lastWorkoutDate!,
                                  )
                                : 'Start workout',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to get icon based on template type
  IconData _getTemplateIcon(WorkoutTemplate template) {
    // You can customize this based on your template categories or names
    final name = template.name.toLowerCase();
    if (name.contains('chest') || name.contains('push')) {
      return Icons.fitness_center;
    } else if (name.contains('leg') || name.contains('squat')) {
      return Icons.directions_run;
    } else if (name.contains('back') || name.contains('pull')) {
      return Icons.sports_gymnastics;
    } else if (name.contains('cardio') || name.contains('run')) {
      return Icons.favorite;
    } else if (name.contains('core') || name.contains('abs')) {
      return Icons.self_improvement;
    } else if (name.contains('arm') || name.contains('bicep')) {
      return Icons.sports_martial_arts;
    }
    return Icons.fitness_center; // default
  }

  // Helper method to create a more informative exercise summary
  String _getExercisesSummary(WorkoutTemplate template) {
    final count = template.exercises.length;
    if (count == 1) return '1 exercise';
    if (count <= 3) return '$count exercises';
    if (count <= 6) return '$count exercises • Quick';
    return '$count exercises • Full workout';
  }

  // -------------------------------------

  String _formatLastWorkoutDate(DateTime lastWorkoutDate) {
    final now = DateTime.now();
    final difference = now.difference(lastWorkoutDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 3;
    } else if (width > 400) {
      return 2;
    } else {
      return 1;
    }
  }
}

_showDialogWorkout(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const Text(
                      'Start Workout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 36), // Balance the close button
                  ],
                ),
              ),

              // Content
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Empty Workout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a new workout session without\na predefined routine',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle starting an empty workout
                          Navigator.of(context).pop();
                          // Add your workout start logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start Workout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

_showWorkoutTemplateDialog(BuildContext context, template) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      template.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // close the dialog
                        Navigator.pop(context);
                        // navigate to edit screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return NewTemplateScreen(template: template);
                            },
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                      child: Text(
                        'Edit',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Last Performed
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Last Performed: Yesterday', // This should dynamically show the last workout date
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Exercise List (This should be populated by the template's exercises)
              Expanded(
                child: ListView.builder(
                  itemCount: template.exercises.length,
                  itemBuilder: (context, index) {
                    return _buildExerciseItem(
                      template.exercises[index].image,
                      template.exercises[index].name,
                      template.exercises[index].category,
                    );
                  },
                ),
              ),

              // Start Workout Button
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      // Handle start workout
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkoutTrackingScreen(workoutTemplate: template),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Start Workout',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildExerciseItem(
  String image,
  String exerciseName,
  String muscleGroup,
) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      print(image);
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              // Exercise Icon
              Container(
                margin: const EdgeInsets.only(bottom: 5.0),
                child: image != ""
                    ? Image.asset(image, width: 60, height: 60)
                    : Icon(
                        Icons.fitness_center_outlined,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),

              const SizedBox(width: 16),

              // Exercise Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      muscleGroup,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Info Button
              Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.help_outline,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

_deleteDialog(context, template) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Template?'),
        content: Text(
          'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              WorkoutTemplateManager().deleteTemplate(template.id);
              Navigator.of(context).pop(); // Dismiss the dialog after deletion
              // You might want to show a SnackBar or other confirmation here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Highlight delete action
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
