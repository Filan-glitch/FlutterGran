import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/screens/new_game_screen.dart';
import 'app/theme.dart';

void main() {
  runApp(const ProviderScope(child: FlutterGranApp()));
}

class FlutterGranApp extends StatelessWidget {
  const FlutterGranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterGran',
      // One theme, always dark. A scoreboard read across a room in a garage
      // has no business being white, and a light variant would mean a second
      // set of decisions for a situation that does not arise.
      theme: buildTheme(),
      home: const NewGameScreen(),
    );
  }
}
