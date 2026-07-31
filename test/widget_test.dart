import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/main.dart';

void main() {
  testWidgets('the game screen opens on a fresh 501 leg', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FlutterGranApp()));

    expect(find.text('501 · double out'), findsOneWidget);
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);

    // Both players start on the full score.
    expect(find.text('501'), findsNWidgets(2));

    // Nothing to undo yet.
    final undo = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.undo),
    );
    expect(undo.onPressed, isNull);
  });
}
