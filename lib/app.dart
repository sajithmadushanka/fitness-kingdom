import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/navigations/app_navigation.dart';
import 'package:fitness_kingdom/screens/home_screens/home_screen.dart';
import 'package:fitness_kingdom/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Kingdom',

      // Localization setup
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // Theme setup
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode
          .system, // Automatically switches between light and dark mode
      initialRoute: AppNavigation.home,
      routes: {
        AppNavigation.home: (context) => const HomeScreen(),
        // AppNavigation.workouts: (context) =>
        //     const WorkoutsScreen(), // Create this screen
        // AppNavigation.progress: (context) =>
        //     const ProgressScreen(), // Create this screen
        // AppNavigation.profile: (context) =>
        //     const ProfileScreen(), // Create this screen
      },
    );
  }
}
