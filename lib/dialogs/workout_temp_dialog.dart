import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/exercise.dart'; // Make sure this path is correct

// Ensure this function is globally available or in a utility file
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

class WorkoutTemplateDialog extends StatefulWidget {
  final Set<String> initialSelectedExerciseKeys;

  const WorkoutTemplateDialog({
    super.key,
    this.initialSelectedExerciseKeys = const {},
  });

  @override
  // ignore: library_private_types_in_public_api
  _WorkoutTemplateDialogState createState() => _WorkoutTemplateDialogState();
}

class _WorkoutTemplateDialogState extends State<WorkoutTemplateDialog> {
  String searchQuery = "";
  late Set<String> selectedExercises;
  late Future<Map<String, ExerciseModel>> exercisesFuture;

  @override
  void initState() {
    super.initState();
    selectedExercises = Set<String>.from(widget.initialSelectedExerciseKeys);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) {
      return;
    }
    exercisesFuture = loadExercises(context);
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
      return exercise.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          exercise.category.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1.0,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      // Text(
                      //   "New", // Consider localizing this if it's meant to be "New Template"
                      //   style: theme.textTheme.titleMedium?.copyWith(
                      //     color: colorScheme.primary,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          // Only pop with selected exercises if there are any
                          if (selectedExercises.isNotEmpty) {
                            Navigator.of(context).pop(selectedExercises);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selectedExercises.isNotEmpty
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Add (${selectedExercises.length})",
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: selectedExercises.isNotEmpty
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
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
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
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
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading exercises',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final exercises = snapshot.data!;
                  final filteredExercises = getFilteredExercises(exercises);

                  if (filteredExercises.isEmpty) {
                    return Center(
                      child: Text(
                        'No exercises match your search',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exerciseEntry = filteredExercises[index];
                      final exerciseKey = exerciseEntry.key;
                      final exercise = exerciseEntry.value;
                      final isSelected = selectedExercises.contains(
                        exerciseKey,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: isSelected ? 4 : 2,
                          color: isSelected
                              ? colorScheme.primaryContainer.withValues(
                                  alpha: 0.3,
                                )
                              : colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => toggleExerciseSelection(exerciseKey),
                            borderRadius: BorderRadius.circular(12),
                            splashColor: colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            highlightColor: colorScheme.primary.withValues(
                              alpha: 0.05,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row with name, category, and selection indicator
                                  Row(
                                    children: [
                                      // Exercise image (if available)
                                      if (exercise.image.isNotEmpty)
                                        Container(
                                          width: 50,
                                          height: 50,
                                          margin: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(exercise.image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 50,
                                          height: 50,
                                          margin: const EdgeInsets.only(
                                            right: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.fitness_center,
                                            color: colorScheme.onSurfaceVariant,
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
                                              exercise.name,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color:
                                                        colorScheme.onSurface,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              exercise.category,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
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
                                              ? colorScheme.primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.outline,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                color: colorScheme.onPrimary,
                                                size: 16,
                                              )
                                            : null,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
