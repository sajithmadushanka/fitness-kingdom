class ExerciseModel {
  final int? id;
  final String? name;
  final String? category;
  final String? image;
  final List<String>? instructions;

  ExerciseModel({
    this.id,
    this.name,
    this.category,
    this.image,
    this.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      image: json['image'],
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : [],
    );
  }

  @override
String toString() {
  return 'ExerciseModel(id: $id, name: $name, category: $category, image: $image, instructions: $instructions)';
}

}
