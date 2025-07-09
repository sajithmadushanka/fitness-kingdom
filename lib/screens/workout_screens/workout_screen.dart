import 'package:fitness_kingdom/screens/template_screen/new_template_screen.dart';
import 'package:fitness_kingdom/screens/workout_screens/workout_tranning_screen.dart';
import 'package:flutter/material.dart';

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
            Center(
              child: Text(
                'Workout',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            // // Welcome Section
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.all(24),
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [
            //         colorScheme.primary,
            //         colorScheme.primary.withOpacity(0.8),
            //       ],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Ready to Workout?',
            //         style: textTheme.headlineMedium?.copyWith(
            //           color: colorScheme.onPrimary,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       const SizedBox(height: 8),
            //       Text(
            //         'Choose your workout style and get started',
            //         style: textTheme.bodyMedium?.copyWith(
            //           color: colorScheme.onPrimary.withOpacity(0.9),
            //         ),
            //       ),
            //     ],
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
                          _showWorkoutTemplateDialog(context);
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
                    print("object");
                    // // Handle add template
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

            // Templates Grid
            _buildTemplatesGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesGrid(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Sample template data
    final templates = [
      {
        'name': 'Push Day',
        'exercises': 8,
        'lastWorkout': '2 days ago',
        'icon': Icons.fitness_center,
      },
      {
        'name': 'Pull Day',
        'exercises': 6,
        'lastWorkout': '4 days ago',
        'icon': Icons.sports_gymnastics,
      },
      {
        'name': 'Leg Day',
        'exercises': 7,
        'lastWorkout': '1 week ago',
        'icon': Icons.directions_run,
      },
      {
        'name': 'Cardio',
        'exercises': 4,
        'lastWorkout': '3 days ago',
        'icon': Icons.favorite,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Handle template selection
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      template['icon'] as IconData,
                      color: colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Template Name
                  Text(
                    template['name'] as String,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Exercise Count
                  Text(
                    '${template['exercises']} exercises',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),

                  // Last Workout
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      template['lastWorkout'] as String,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

_showTemplatesDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
                      'Choose Template',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle creating new template
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'New',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Templates List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildTemplateItem(
                      context,
                      'Push Day',
                      'Last: 3 days ago',
                      Icons.fitness_center,
                      [
                        '4 × Incline Bench Press',
                        '4 × Cable Crossover',
                        '4 × Skullcrusher',
                      ],
                      'Chest, Arms',
                    ),
                    _buildTemplateItem(
                      context,
                      'Pull Day',
                      'Last: 1 week ago',
                      Icons.sports_gymnastics,
                      [
                        '4 × Bent Over Row',
                        '4 × Lat Pulldown',
                        '3 × Lateral Raise',
                      ],
                      'Back, Shoulders',
                    ),
                    _buildTemplateItem(
                      context,
                      'Leg Day',
                      'Last: 5 days ago',
                      Icons.directions_run,
                      ['4 × Squats', '4 × Leg Press', '3 × Calf Raises'],
                      'Legs, Glutes',
                    ),
                    _buildTemplateItem(
                      context,
                      'Core & Cardio',
                      'Last: Yesterday',
                      Icons.favorite,
                      ['4 × Decline Crunch', '3 × Plank', '10 min Treadmill'],
                      'Core, Cardio',
                    ),
                    _buildTemplateItem(
                      context,
                      'Full Body',
                      'Last: 2 weeks ago',
                      Icons.accessibility,
                      ['3 × Deadlift', '3 × Bench Press', '3 × Squats'],
                      'Full Body',
                    ),
                  ],
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Show empty workout dialog
                          _showDialogWorkout(context);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Start Empty'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade300),
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
    },
  );
}

Widget _buildTemplateItem(
  BuildContext context,
  String title,
  String lastPerformed,
  IconData icon,
  List<String> exercises,
  String muscleGroups,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: InkWell(
      onTap: () {
        Navigator.of(context).pop();
        // Handle template selection
        _startWorkoutFromTemplate(context, title);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lastPerformed,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              muscleGroups,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...exercises
                .take(3)
                .map(
                  (exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exercise,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (exercises.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${exercises.length - 3} more exercises',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

void _startWorkoutFromTemplate(BuildContext context, String templateName) {
  // Handle starting workout from selected template
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Start $templateName'),
      content: const Text('Starting workout from template...'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

_showWorkoutTemplateDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
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
                      'Day 3',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle edit action
                      },
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
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
                      'Last Performed: Yesterday',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Exercise List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildExerciseItem(
                      Icons.fitness_center,
                      '4 × Incline Bench Press (Barbell)',
                      'Chest',
                    ),
                    _buildExerciseItem(
                      Icons.sports_gymnastics,
                      '4 × Bent Over Row (Barbell)',
                      'Back',
                    ),
                    _buildExerciseItem(
                      Icons.accessibility_new,
                      '4 × Cable Crossover',
                      'Chest',
                    ),
                    _buildExerciseItem(
                      Icons.sports_martial_arts,
                      '4 × Lat Pulldown (Cable)',
                      'Back',
                    ),
                    _buildExerciseItem(
                      Icons.sports_handball,
                      '4 × Skullcrusher (Barbell)',
                      'Arms',
                    ),
                    _buildExerciseItem(
                      Icons.sports_kabaddi,
                      '4 × Decline Crunch',
                      'Core',
                    ),
                    _buildExerciseItem(
                      Icons.sports_mma,
                      '3 × Lateral Raise (Cable)',
                      'Shoulders',
                    ),
                  ],
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
                          builder: (context) => const WorkoutTrackingScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Workout',
                      style: TextStyle(
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
  IconData icon,
  String exerciseName,
  String muscleGroup,
) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        // Exercise Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: Colors.grey.shade700),
        ),

        const SizedBox(width: 16),

        // Exercise Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exerciseName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                muscleGroup,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
            color: Colors.blue.shade400,
          ),
        ),
      ],
    ),
  );
}

// void _startWorkout(BuildContext context) {
//   // Handle starting the workout
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       title: const Text('Workout Started'),
//       content: const Text('Your Day 3 workout has been started successfully!'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Continue'),
//         ),
//       ],
//     ),
//   );
// }
