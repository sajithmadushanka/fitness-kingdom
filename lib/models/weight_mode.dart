// Your model file (e.g., lib/models/weight_mode.dart)

import 'package:hive/hive.dart';

// Make sure this line is EXACTLY like this:
part 'weight_mode.g.dart'; // <--- This must match the expected generated file name

@HiveType(typeId: 5)
class WeightEntry extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double weight;

  WeightEntry({required this.date, required this.weight});
}