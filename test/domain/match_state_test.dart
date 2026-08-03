import 'package:fluttergran/domain/x01/match_state.dart';
import 'package:test/test.dart';

MatchConfig config({int legsToPlay = 3, int players = 2}) => MatchConfig(
  startScore: 501,
  playerIds: [for (var i = 1; i <= players; i++) i],
  legsToPlay: legsToPlay,
);

void main() {
  group('how many legs win it', () {
    test('best of N needs more than half of N', () {
      expect(config(legsToPlay: 1).legsToWin, 1);
      expect(config(legsToPlay: 3).legsToWin, 2);
      expect(config(legsToPlay: 5).legsToWin, 3);
      expect(config(legsToPlay: 7).legsToWin, 4);
    });
  });

  group('calling the match', () {
    test('nobody has won before a leg has been played', () {
      final state = foldMatch(config(), const []);
      expect(state.winnerId, isNull);
      expect(state.isFinished, isFalse);
      expect(state.legsWon, {1: 0, 2: 0});
    });

    test('best of three is over at two nil', () {
      final state = foldMatch(config(), const [1, 1]);
      expect(state.legsWon, {1: 2, 2: 0});
      expect(state.winnerId, 1);
      expect(state.isFinished, isTrue);
    });

    test('best of three is not over at one all', () {
      final state = foldMatch(config(), const [1, 2]);
      expect(state.legsWon, {1: 1, 2: 1});
      expect(state.winnerId, isNull);
      expect(state.isFinished, isFalse);
    });

    test('best of five is over at three one', () {
      final state = foldMatch(config(legsToPlay: 5), const [1, 2, 1, 1]);
      expect(state.legsWon, {1: 3, 2: 1});
      expect(state.winnerId, 1);
    });

    test('best of five is not over at two two', () {
      final state = foldMatch(config(legsToPlay: 5), const [1, 2, 1, 2]);
      expect(state.winnerId, isNull);
      expect(state.legsPlayed, 4);
    });

    test('a single leg decides a best of one', () {
      final state = foldMatch(config(legsToPlay: 1), const [2]);
      expect(state.winnerId, 2);
    });

    test('legs recorded after the match is decided cannot change it', () {
      final state = foldMatch(config(), const [1, 1, 2, 2]);
      expect(state.winnerId, 1);
      expect(state.legsWon, {1: 2, 2: 0});
      expect(state.legsPlayed, 2, reason: 'the extra legs were never played');
    });

    test('three players share the same threshold', () {
      final state = foldMatch(
        config(legsToPlay: 3, players: 3),
        const [3, 3],
      );
      expect(state.legsWon, {1: 0, 2: 0, 3: 2});
      expect(state.winnerId, 3);
    });
  });

  group('who throws first', () {
    test('the first leg goes to the first seat', () {
      expect(config().startingSeatFor(0), 0);
      expect(foldMatch(config(), const []).nextStartingSeat, 0);
    });

    test('two players alternate, leg by leg', () {
      final format = config(legsToPlay: 5);
      expect(format.startingSeatFor(0), 0);
      expect(format.startingSeatFor(1), 1);
      expect(format.startingSeatFor(2), 0);
      expect(format.startingSeatFor(3), 1);
    });

    test('the second leg is thrown first by the second seat', () {
      final state = foldMatch(config(legsToPlay: 5), const [1]);
      expect(state.nextLegNumber, 1);
      expect(state.nextStartingSeat, 1);
    });

    test('the third leg comes back round to the first seat', () {
      final state = foldMatch(config(legsToPlay: 5), const [1, 2]);
      expect(state.nextLegNumber, 2);
      expect(state.nextStartingSeat, 0);
    });

    test('four players cycle through every seat', () {
      final format = config(legsToPlay: 7, players: 4);
      expect(
        [for (var leg = 0; leg < 6; leg++) format.startingSeatFor(leg)],
        [0, 1, 2, 3, 0, 1],
      );
    });

    test('the next leg config carries the seat and the leg rules', () {
      final next = foldMatch(config(legsToPlay: 3), const [1]).nextLegConfig;
      expect(next, isNotNull);
      expect(next!.startingSeat, 1);
      expect(next.startScore, 501);
      expect(next.playerIds, [1, 2]);
      expect(next.doubleOut, isTrue);
    });

    test('there is no next leg once the match is decided', () {
      expect(foldMatch(config(), const [1, 1]).nextLegConfig, isNull);
    });
  });
}
