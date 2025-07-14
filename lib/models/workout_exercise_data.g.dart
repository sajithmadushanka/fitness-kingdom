// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_exercise_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutExerciseDataAdapter extends TypeAdapter<WorkoutExerciseData> {
  @override
  final int typeId = 4;

  @override
  WorkoutExerciseData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutExerciseData(
      exerciseId: fields[0] as String,
      exerciseName: fields[1] as String,
      sets: (fields[2] as List).cast<WorkoutSetData>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutExerciseData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.sets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutExerciseDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
