import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// The strings for whatever locale this [BuildContext] resolves to.
///
/// `AppLocalizations.of(context)!` is force-unwrapped because a
/// [MaterialApp]/[WidgetsApp] with [AppLocalizations.localizationsDelegates]
/// installed (which `main.dart` always does) guarantees the lookup, at any
/// [BuildContext] below it, never returns null.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Falls back to a seat label for a player who has since been deleted.
String nameFor(BuildContext context, Map<int, String> names, int playerId) =>
    names[playerId] ?? context.l10n.playerFallbackName(playerId);
