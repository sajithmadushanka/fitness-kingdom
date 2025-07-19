import 'package:fitness_kingdom/screens/exercises_screens/exercises_screen.dart';
import 'package:fitness_kingdom/screens/home_screens/home_screen_content.dart';
import 'package:fitness_kingdom/screens/weight_tracker.dart';
import 'package:fitness_kingdom/screens/workout_screens/workout_screen.dart';
import 'package:fitness_kingdom/shared/app_nav_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Index for the BottomNavigationBar

  // List of widgets for each tab
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(), // The actual home screen content
    const WorkoutScreen(),
    const WeightTrackerScreen(),
    const ExercisesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isDarkMode = false;

  void toggleMode() {
    isDarkMode = !isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    // Access the defined theme for colors and text styles
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fitness Kingdom',
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
