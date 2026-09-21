import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/board/led_command.dart';
import 'package:test/test.dart';

/// Bytes as the captures in `docs/BOARD_PROTOCOL.md` write them.
List<int> hex(String spaced) => [
  for (final byte in spaced.split(' ')) int.parse(byte, radix: 16),
];

void main() {
  group('ring frame', () {
    test('is twenty palette codes, indexed by board number', () {
      final frame = encodeLedCommand(
        RingPaint.only({1: RingColor.red, 20: RingColor.white}),
      );
      expect(
        frame,
        hex('01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07'),
      );
    });

    test('off is twenty zero bytes', () {
      expect(encodeLedCommand(RingPaint.off), List.filled(20, 0));
      expect(RingPaint.off.isOff, isTrue);
    });

    test('compares by colours, so an unchanged ring can be skipped', () {
      expect(
        RingPaint.only({3: RingColor.yellow}),
        RingPaint.only({3: RingColor.yellow}),
      );
      expect(
        RingPaint.only({3: RingColor.yellow}),
        isNot(RingPaint.only({3: RingColor.orange})),
      );
    });
  });

  group('hit flash', () {
    test('matches the captured single-1 frame', () {
      final frame = encodeLedCommand(
        const HitFlash(
          number: 1,
          kind: HitFlashKind.single,
          primary: Rgb(0xFF, 0, 0),
          secondary: Rgb(0xFF, 0x95, 0),
        ),
      );
      expect(frame, hex('01 FF 00 00 FF 95 00 00 00 00 1C 00 14 00 00 01'));
    });

    test('carries the op for the ring and the target id for the number', () {
      final frame = encodeLedCommand(
        const HitFlash(
          number: 20,
          kind: HitFlashKind.tripled,
          primary: Rgb(1, 2, 3),
          secondary: Rgb(4, 5, 6),
          speed: 300,
        ),
      );
      expect(frame, hex('03 01 02 03 04 05 06 00 00 00 19 00 FF 00 00 01'));
    });
  });

  group('effect frame', () {
    test('lays out three colours and speed, ending in 01', () {
      final frame = encodeLedCommand(
        const EffectFrame(
          LedEffect.triFade,
          a: Rgb(1, 2, 3),
          b: Rgb(4, 5, 6),
          c: Rgb(7, 8, 9),
          speed: 12,
        ),
      );
      expect(frame, hex('1F 01 02 03 04 05 06 07 08 09 00 00 0C 00 00 01'));
    });

    test('clamps speed to the range the board takes', () {
      final frame = encodeLedCommand(
        const EffectFrame(LedEffect.flicker, speed: 99),
      );
      expect(frame[12], maxEffectSpeed);
    });

    test('adds the mode bytes the captured frames carry', () {
      expect(
        encodeLedCommand(const EffectFrame(LedEffect.rainbowFlicker)),
        hex('0D 00 00 00 00 00 00 00 00 00 00 02 0A 02 00 01'),
      );
      expect(encodeLedCommand(const EffectFrame(LedEffect.nextSweep))[10], 0x10);
      expect(encodeLedCommand(const EffectFrame(LedEffect.pulse))[4], 0x7D);
    });

    test('leaves out hunt flicker, which does nothing on a 132', () {
      expect(LedEffect.values.map((effect) => effect.op), isNot(contains(0x19)));
    });
  });

  test('never produces a settings frame', () {
    // The board's settings frames are 12 bytes long. Nothing the encoder
    // builds is.
    final commands = <LedCommand>[
      RingPaint.off,
      for (final kind in HitFlashKind.values)
        HitFlash(
          number: 7,
          kind: kind,
          primary: Rgb.black,
          secondary: Rgb.black,
        ),
      for (final effect in LedEffect.values) EffectFrame(effect),
    ];
    for (final command in commands) {
      expect(encodeLedCommand(command).length, anyOf(16, 20));
    }
  });

  group('fake board', () {
    test('records commands only while connected', () async {
      final board = FakeBoardSource();
      await board.sendLed(RingPaint.off);
      expect(board.ledCommands, isEmpty);

      await board.connect();
      await board.sendLed(RingPaint.off);
      expect(board.ledCommands, [RingPaint.off]);
      await board.dispose();
    });
  });
}
