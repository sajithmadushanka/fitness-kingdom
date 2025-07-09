import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/models/workout_model.dart';
import 'package:fitness_kingdom/screens/workout_screens/workout_tranning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/exercise.dart';

class WorkoutTemplateDialog extends StatefulWidget {
  const WorkoutTemplateDialog({super.key});

  @override
  _WorkoutTemplateDialogState createState() => _WorkoutTemplateDialogState();
}

class _WorkoutTemplateDialogState extends State<WorkoutTemplateDialog> {
  String searchQuery = "";
  Set<String> selectedExercises = {};
  late Future<Map<String, ExerciseModel>> exercisesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    exercisesFuture = loadExercises(context);
  }

  Future<Map<String, ExerciseModel>> loadExercises(BuildContext context) async {
    final locale = context.locale;
    final String langCode = '${locale.languageCode}-${locale.countryCode}';

    final String jsonString = await rootBundle.loadString(
      'assets/langs/$langCode.json',
    );
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final Map<String, dynamic> exercisesData = jsonData['exercises'];

    return exercisesData.map(
      (key, value) => MapEntry(key, ExerciseModel.fromJson(value)),
    );
  }

  void toggleExerciseSelection(String exerciseKey) {
    setState(() {
      if (selectedExercises.contains(exerciseKey)) {
        selectedExercises.remove(exerciseKey);
      } else {
        selectedExercises.add(exerciseKey);
      }
    });
  }

  List<MapEntry<String, ExerciseModel>> getFilteredExercises(
    Map<String, ExerciseModel> exercises,
  ) {
    final exerciseEntries = exercises.entries.toList();

    if (searchQuery.isEmpty) {
      return exerciseEntries;
    }

    return exerciseEntries.where((entry) {
      final exercise = entry.value;
      return exercise.name!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          exercise.category!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1.0,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      Text(
                        "New",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          if (selectedExercises.isNotEmpty) {
                            Navigator.of(context).pop(selectedExercises);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selectedExercises.isNotEmpty
                                ? Colors.blue
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Add (${selectedExercises.length})",
                            style: TextStyle(
                              color: selectedExercises.isNotEmpty
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ),

            // Exercise Cards List
            Expanded(
              child: FutureBuilder<Map<String, ExerciseModel>>(
                future: exercisesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Error loading exercises',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No exercises found',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  final exercises = snapshot.data!;
                  final filteredExercises = getFilteredExercises(exercises);

                  if (filteredExercises.isEmpty) {
                    return Center(
                      child: Text(
                        'No exercises match your search',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exerciseEntry = filteredExercises[index];
                      final exerciseKey = exerciseEntry.key;
                      final exercise = exerciseEntry.value;
                      final isSelected = selectedExercises.contains(
                        exerciseKey,
                      );

                      // print(exercise.image!);
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: isSelected ? 4 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => toggleExerciseSelection(exerciseKey),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row with name, category, and selection indicator
                                  Row(
                                    children: [
                                      // Exercise image (if available)
                                      if (exercise.image!.toString() != "")
                                        Container(
                                          width: 50,
                                          height: 50,
                                          margin: EdgeInsets.only(right: 16),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                exercise.image!
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 50,
                                          height: 50,
                                          margin: EdgeInsets.only(right: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.fitness_center,
                                            color: Colors.grey[600],
                                            size: 24,
                                          ),
                                        ),

                                      // Exercise name and category
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exercise.name!,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              exercise.category!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Selection indicator
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),

                                  // Instructions
                                  // if (exercise.instructions!.isNotEmpty) ...[
                                  //   SizedBox(height: 12),
                                  //   Text(
                                  //     "Instructions:",
                                  //     style: TextStyle(
                                  //       fontSize: 14,
                                  //       fontWeight: FontWeight.w600,
                                  //       color: Colors.black87,
                                  //     ),
                                  //   ),
                                  //   SizedBox(height: 8),
                                  //   ...exercise.instructions!
                                  //       .asMap()
                                  //       .entries
                                  //       .map((entry) {
                                  //         final stepIndex = entry.key + 1;
                                  //         final instruction = entry.value;
                                  //         print(stepIndex);
                                  //         print(instruction);
                                  //         return Padding(
                                  //           padding: EdgeInsets.only(bottom: 4),
                                  //           child: Text(
                                  //             "$stepIndex. $instruction",
                                  //             style: TextStyle(
                                  //               fontSize: 13,
                                  //               color: Colors.grey[700],
                                  //               height: 1.4,
                                  //             ),
                                  //           ),
                                  //         );
                                  //       }),
                                  // ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
