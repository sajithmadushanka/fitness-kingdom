import 'package:hive/hive.dart';
// Ensure this is imported if used in ExerciseModel

part 'exercise.g.dart'; // This line will be generated

@HiveType(typeId: 0) // Unique typeId for this model
class ExerciseModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String image;
  @HiveField(4)
  final List<String> instructions;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      instructions: List<String>.from(json['instructions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image': image,
      'instructions': instructions,
    };
  }

  // Override hashCode and equals for proper Set behavior
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModel && runtimeType == other.runtimeType && id == other.id;
}