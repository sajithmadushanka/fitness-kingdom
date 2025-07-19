

import '../../models/exercise.dart';

List<MapEntry<String, ExerciseModel>> getFilteredExercises(
  Map<String, ExerciseModel> exercises,
  String searchQuery,
  String selectedCategory,
) {
  final allExercises = exercises.entries.toList();

  return allExercises.where((entry) {
    final exercise = entry.value;
    final nameMatches = exercise.name.toLowerCase().contains(searchQuery.toLowerCase());
    
    final categoryMatches = selectedCategory == 'All Categories' || exercise.category == selectedCategory;
    
    return nameMatches && categoryMatches;
  }).toList();
}