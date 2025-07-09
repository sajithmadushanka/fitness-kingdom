import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_kingdom/app.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US')],
      path: 'assets/langs', 
      fallbackLocale: Locale('en', 'US'),
      child: MyApp()
    ),
  );
}