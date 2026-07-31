import 'package:fluttergran/data/board/granboard_segment_map.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:test/test.dart';

/// Splits a `column.row` code into its two coordinates.
({int column, int row}) coords(String code) {
  final parts = code.split('.');
  return (column: int.parse(parts[0]), row: int.parse(parts[1]));
}

void main() {
  group('coverage', () {
    test('every scoring area on the board has exactly one code', () {
      expect(granboardSegmentMap, hasLength(82));
      expect(granboardSegmentMap.values.toSet(), hasLength(82));
      expect(granboardSegmentMap.values.toSet(), Segment.all.toSet());
    });

    test('no code is reused for two segments', () {
      expect(granboardSegmentMap.keys.toSet(), hasLength(82));
    });

    test('every wedge has all four rings', () {
      for (var wedge = 1; wedge <= 20; wedge++) {
        expect(wedgeCodes[wedge], hasLength(4), reason: 'wedge $wedge');
      }
    });
  });

  group('the sensor matrix', () {
    test('is 12 columns of 7 rows', () {
      for (final code in granboardSegmentMap.keys) {
        final position = coords(code);
        expect(position.column, inInclusiveRange(0, 11), reason: code);
        expect(position.row, inInclusiveRange(0, 6), reason: code);
      }
    });

    test('leaves exactly two slots empty, and they are 4.1 and 8.1', () {
      final used = granboardSegmentMap.keys.toSet();
      final unused = <String>{
        for (var column = 0; column < 12; column++)
          for (var row = 0; row < 7; row++)
            if (!used.contains('$column.$row')) '$column.$row',
      };
      expect(unused, unusedMatrixSlots);
    });

    test('the overflow columns hold a bull plus five displaced doubles', () {
      // Ten columns serve two wedges each: eight segments will not fit in seven
      // rows, so one double per column spills into column 4 or column 8. That
      // this reconciles exactly is the strongest check that the table is right.
      for (final column in [4, 8]) {
        final inColumn = granboardSegmentMap.entries
            .where((entry) => coords(entry.key).column == column)
            .map((entry) => entry.value)
            .toList();

        expect(inColumn, hasLength(6), reason: 'column $column');
        expect(
          inColumn.where((segment) => segment.ring == Ring.doubleRing),
          hasLength(5),
          reason: 'column $column',
        );
        expect(
          inColumn.where(
            (segment) =>
                segment.ring == Ring.outerBull || segment.ring == Ring.innerBull,
          ),
          hasLength(1),
          reason: 'column $column',
        );
      }
    });

    test('every other column holds exactly seven segments', () {
      for (var column = 0; column < 12; column++) {
        if (column == 4 || column == 8) continue;
        final inColumn = granboardSegmentMap.keys.where(
          (code) => coords(code).column == column,
        );
        expect(inColumn, hasLength(7), reason: 'column $column');
      }
    });
  });

  group('known landmarks', () {
    test('the codes quoted by every source', () {
      expect(granboardSegmentMap['3.4'], const Segment(20, Ring.triple));
      expect(granboardSegmentMap['3.6'], const Segment(20, Ring.doubleRing));
      expect(granboardSegmentMap['3.5'], const Segment(20, Ring.outerSingle));
      expect(granboardSegmentMap['3.3'], const Segment(20, Ring.innerSingle));
      expect(granboardSegmentMap['7.0'], const Segment(3, Ring.triple));
      expect(granboardSegmentMap['8.4'], const Segment(3, Ring.doubleRing));
      expect(granboardSegmentMap['8.0'], Segment.outerBull);
      expect(granboardSegmentMap['4.0'], Segment.innerBull);
    });

    test('the bulls sit in the two overflow columns', () {
      expect(coords(outerBullCode).column, 8);
      expect(coords(innerBullCode).column, 4);
    });
  });
}
