import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/screens/game_screen.dart';

void main() {
  runApp(const ProviderScope(child: FlutterGranApp()));
}

class FlutterGranApp extends StatelessWidget {
  const FlutterGranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterGran',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E8449)),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E8449),
          brightness: Brightness.dark,
        ),
      ),
      home: const GameScreen(),
    );
  }
}
