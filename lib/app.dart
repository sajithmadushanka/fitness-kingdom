import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/navigations/app_navigation.dart';
import 'package:fitness_kingdom/screens/home_screens/home_screen.dart';
import 'package:fitness_kingdom/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Kingdom',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: AppNavigation.home,
      routes: {
        AppNavigation.home: (context) => HomeScreen(toggleTheme: toggleTheme),
      },
    );
  }
}
