import 'package:flutter/material.dart';

class WorkoutExercise {
  final String name;
  final String category;
  final int reps;
  final IconData icon;
  bool isSelected;

  WorkoutExercise({
    required this.name,
    required this.category,
    required this.reps,
    required this.icon,
    required this.isSelected,
  });

  
}
