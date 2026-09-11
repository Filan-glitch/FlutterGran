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
