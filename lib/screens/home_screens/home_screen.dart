import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/models/workout_model.dart';
import 'package:fitness_kingdom/navigations/app_navigation.dart';
import 'package:fitness_kingdom/screens/home_screens/home_screen_content.dart';
import 'package:fitness_kingdom/screens/workout_screens/workout_screen.dart';
import 'package:fitness_kingdom/shared/app_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/exercise.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Index for the BottomNavigationBar

  // List of widgets for each tab
  static final List<Widget> _widgetOptions = <Widget>[
    HomeContent(), // The actual home screen content
    WorkoutScreen(),
    const Center(child: Text('Progress Screen Placeholder')),
    const Center(child: Text('Profile Screen Placeholder')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<Map<String, ExerciseModel>> loadExercises(BuildContext context) async {
     final locale = context.locale;
  final String langCode = '${locale.languageCode}-${locale.countryCode}';
  // print('Loading exercises for locale: $langCode');

  final String jsonString = await rootBundle.loadString('assets/langs/$langCode.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);

  // Extract only the 'exercises' part
  final Map<String, dynamic> exercisesData = jsonData['exercises'];

  return exercisesData.map(
    (key, value) => MapEntry(key, ExerciseModel.fromJson(value)),
  );
}


  // void testExerciseLoading() async {
  //   final exercises = await loadExercises();

  //   exercises.forEach((key, exercise) {
  //     print('Key: $key');
  //     print('Exercise: $exercise');
  //     print('------------');
  //   });
  // }

  @override
  void initState() {
 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  // loadExercises(context).then((data) {
  //   data.forEach((key, value) {
  //     print('Key: $key');
  //     print('Exercise: $value');
  //   });
  // });

    // Access the defined theme for colors and text styles
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'exercises.dumbbell_bench_press.name'.tr(),
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.notifications_outlined,
        //       color: colorScheme.onPrimary,
        //     ),
        //     onPressed: () {
        //       // TODO: Implement notification logic
        //     },
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.settings_outlined, color: colorScheme.onPrimary),
        //     onPressed: () {
        //       // TODO: Implement settings logic
        //     },
        //   ),
        // ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
