import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
