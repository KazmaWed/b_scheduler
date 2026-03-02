import 'package:flutter/material.dart';

import 'package:example/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const debugView = bool.fromEnvironment('DEBUG_VIEW', defaultValue: false);

    final theme = ThemeData.light().copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink).copyWith(
        tertiary: Colors.purple,
        tertiaryContainer: Colors.purple.shade100,
        tertiaryFixed: Colors.purple,
        tertiaryFixedDim: Colors.purple.shade700,
      ),
      scaffoldBackgroundColor: Colors.white,
    );

    return MaterialApp(
      title: 'B Scheduler',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: LoginScreen(debugView: debugView),
    );
  }
}
