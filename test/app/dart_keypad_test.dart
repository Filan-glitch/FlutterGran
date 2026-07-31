import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/widgets/dart_keypad.dart';
import 'package:fluttergran/domain/segment.dart';

Future<void> pumpKeypad(
  WidgetTester tester,
  List<Segment> entered, {
  VoidCallback? onMiss,
  Set<Segment> highlight = const {},
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DartKeypad(
          onDart: entered.add,
          onMiss: onMiss ?? () {},
          highlight: highlight,
        ),
      ),
    ),
  );
}

void main() {
  group('entering darts', () {
    testWidgets('a wedge alone is a single', (tester) async {
      final entered = <Segment>[];
      await pumpKeypad(tester, entered);

      await tester.tap(find.text('20'));
      await tester.pump();

      expect(entered.single, const Segment(20, Ring.outerSingle));
      expect(entered.single.value, 20);
    });

    testWidgets('treble then a wedge is a treble', (tester) async {
      final entered = <Segment>[];
      await pumpKeypad(tester, entered);

      await tester.tap(find.text('Treble'));
      await tester.pump();
      await tester.tap(find.text('20'));
      await tester.pump();

      expect(entered.single, const Segment(20, Ring.triple));
      expect(entered.single.value, 60);
    });

    testWidgets('double then a wedge is a double', (tester) async {
      final entered = <Segment>[];
      await pumpKeypad(tester, entered);

      await tester.tap(find.text('Double'));
      await tester.pump();
      await tester.tap(find.text('16'));
      await tester.pump();

      expect(entered.single, const Segment(16, Ring.doubleRing));
      expect(entered.single.value, 32);
    });

    testWidgets('the ring resets to single after every dart', (tester) async {
      final entered = <Segment>[];
      await pumpKeypad(tester, entered);

      await tester.tap(find.text('Treble'));
      await tester.pump();
      await tester.tap(find.text('20'));
      await tester.pump();
      // Without the reset this second tap would silently record another treble.
      await tester.tap(find.text('5'));
      await tester.pump();

      expect(entered, [
        const Segment(20, Ring.triple),
        const Segment(5, Ring.outerSingle),
      ]);
    });

    testWidgets('all twenty wedges are on the keypad', (tester) async {
      final entered = <Segment>[];
      await pumpKeypad(tester, entered);

      for (var number = 1; number <= 20; number++) {
        expect(find.text('$number'), findsWidgets, reason: 'wedge $number');
      }
    });
  });

  group('bulls and misses', () {
    testWidgets('25 is the outer bull and does not check out', (tester) async {
      final entered = <Segment>[];
      await pumpKeypad(tester, entered);

      await tester.tap(find.text('25'));
      await tester.pump();

      expect(entered.single, Segment.outerBull);
      expect(entered.single.value, 25);
      expect(entered.single.isDouble, isFalse);
    });

    testWidgets('Bull is the inner bull and does check out', (tester) async {
      final entered = <Segment>[];
      await pumpKeypad(tester, entered);

      await tester.tap(find.text('Bull'));
      await tester.pump();

      expect(entered.single, Segment.innerBull);
      expect(entered.single.value, 50);
      expect(entered.single.isDouble, isTrue);
    });

    testWidgets('the bulls ignore the ring selector', (tester) async {
      final entered = <Segment>[];
      await pumpKeypad(tester, entered);

      await tester.tap(find.text('Treble'));
      await tester.pump();
      await tester.tap(find.text('Bull'));
      await tester.pump();

      // There is no treble bull; the key means what it says.
      expect(entered.single, Segment.innerBull);
    });

    testWidgets('Miss reports a miss, not a dart', (tester) async {
      final entered = <Segment>[];
      var missed = 0;
      await pumpKeypad(tester, entered, onMiss: () => missed++);

      await tester.tap(find.text('Miss'));
      await tester.pump();

      expect(missed, 1);
      expect(entered, isEmpty);
    });
  });

  group('checkout highlighting', () {
    testWidgets('a highlighted key only stands out in its own ring', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      final entered = <Segment>[];
      await pumpKeypad(
        tester,
        entered,
        highlight: {const Segment(16, Ring.doubleRing)},
      );

      // In singles mode the 16 key means S16, which is not the target.
      expect(
        tester.getSemantics(find.text('16')),
        isNot(isSemantics(isSelected: true)),
      );

      await tester.tap(find.text('Double'));
      await tester.pump();

      expect(
        tester.getSemantics(find.text('16')),
        isSemantics(isSelected: true),
      );

      handle.dispose();
    });

    testWidgets('the bull highlights when it is the finish', (tester) async {
      final handle = tester.ensureSemantics();

      await pumpKeypad(tester, [], highlight: {Segment.innerBull});

      expect(
        tester.getSemantics(find.text('Bull')),
        isSemantics(isSelected: true),
      );
      expect(
        tester.getSemantics(find.text('25')),
        isNot(isSemantics(isSelected: true)),
      );

      handle.dispose();
    });
  });
}
