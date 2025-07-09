import 'package:flutter/material.dart';

class WorkoutTrackingScreen extends StatefulWidget {
  const WorkoutTrackingScreen({super.key});

  @override
  State<WorkoutTrackingScreen> createState() => _WorkoutTrackingScreenState();
}

class _WorkoutTrackingScreenState extends State<WorkoutTrackingScreen> {
  bool isMinimized = false;
  int workoutDuration = 4; // in minutes
  
  List<Exercise> exercises = [
    Exercise(
      name: 'Incline Bench Press (Barbell)',
      sets: [
        WorkoutSet(weight: 10, reps: 10, previous: '10 kg × 10'),
        WorkoutSet(weight: 15, reps: 10, previous: '15 kg × 10'),
        WorkoutSet(weight: 15, reps: 6, previous: '15 kg × 6'),
        WorkoutSet(weight: 15, reps: 7, previous: '15 kg × 7'),
      ],
    ),
    Exercise(
      name: 'Bent Over Row (Barbell)',
      sets: [
        WorkoutSet(weight: 10, reps: 12, previous: '10 kg × 12'),
        WorkoutSet(weight: 10, reps: 12, previous: '10 kg × 12'),
        WorkoutSet(weight: 10, reps: 12, previous: '10 kg × 12'),
        WorkoutSet(weight: 15, reps: 8, previous: '15 kg × 8'),
      ],
    ),
  ];

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
                  // Back Button
                  Container(
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
                      const Text(
                        'Day 3',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    '0:0$workoutDuration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Notes',
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
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return _buildExerciseCard(exercises[index], index);
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

  Widget _buildExerciseCard(Exercise exercise, int exerciseIndex) {
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
            WorkoutSet set = entry.value;
            return _buildSetRow(exerciseIndex, setIndex, set);
          }).toList(),
          
          // Add Set Button
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  exercises[exerciseIndex].sets.add(
                    WorkoutSet(weight: 0, reps: 0, previous: '- kg × -'),
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

  Widget _buildSetRow(int exerciseIndex, int setIndex, WorkoutSet set) {
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
          
          // Previous
          Expanded(
            child: Text(
              set.previous,
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
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {
                  exercises[exerciseIndex].sets[setIndex] = WorkoutSet(
                    weight: int.tryParse(value) ?? 0,
                    reps: set.reps,
                    previous: set.previous,
                    isCompleted: set.isCompleted,
                  );
                });
              },
              controller: TextEditingController(text: set.weight.toString()),
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
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {
                  exercises[exerciseIndex].sets[setIndex] = WorkoutSet(
                    weight: set.weight,
                    reps: int.tryParse(value) ?? 0,
                    previous: set.previous,
                    isCompleted: set.isCompleted,
                  );
                });
              },
              controller: TextEditingController(text: set.reps.toString()),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Check Button
          GestureDetector(
            onTap: () {
              setState(() {
                exercises[exerciseIndex].sets[setIndex] = WorkoutSet(
                  weight: set.weight,
                  reps: set.reps,
                  previous: set.previous,
                  isCompleted: !set.isCompleted,
                );
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Workout'),
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
        content: const Text('Select an exercise to add to your workout.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add new exercise logic here
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class Exercise {
  final String name;
  final List<WorkoutSet> sets;

  Exercise({required this.name, required this.sets});
}

class WorkoutSet {
  final int weight;
  final int reps;
  final String previous;
  final bool isCompleted;

  WorkoutSet({
    required this.weight,
    required this.reps,
    required this.previous,
    this.isCompleted = false,
  });
}