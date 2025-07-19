import 'package:hive/hive.dart';

@HiveType(typeId: 6)
class WorkoutDay extends HiveObject {
  @HiveField(0)
  final DateTime date;

  WorkoutDay(this.date);
}
