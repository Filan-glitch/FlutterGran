The Flutter app: Riverpod providers and controllers, screens, widgets, sound,
the board's LED ring and the update flow.

A controller per mode, such as `GameController`, owns the leg's dart log,
listens to the board's event stream and stores each dart; screens watch the
providers in `providers.dart`. Sound and lights only watch the game, and
never change it. Layout tiers and design tokens live in `theme.dart`.

More in the handbook:
[Architecture](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/ARCHITECTURE.md),
[Development](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/DEVELOPMENT.md),
[Rules screens](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/RULES_SCREENS.md),
[Releasing](https://github.com/Filan-glitch/FlutterGran/blob/main/docs/RELEASING.md).
