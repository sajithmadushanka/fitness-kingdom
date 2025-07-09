import 'package:flutter/material.dart';

// This widget encapsulates the BottomNavigationBar logic.
// It receives the currently selected index and a callback function
// to notify the parent when an item is tapped.
class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Access the defined theme for colors to maintain consistency
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center_outlined),
          activeIcon: Icon(Icons.fitness_center),
          label: 'Workouts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: colorScheme.primary, // Uses primary color from your theme
      unselectedItemColor: colorScheme.onSurfaceVariant, // Uses a toned-down color from your theme
      onTap: onItemTapped, // Pass the callback to handle taps
      type: BottomNavigationBarType.fixed, // Keeps all items visible
      backgroundColor: colorScheme.surface, // Uses surface color from your theme
      elevation: 8,
    );
  }
}
