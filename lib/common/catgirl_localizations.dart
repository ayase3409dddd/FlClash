import 'package:fl_clash/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'generated/catgirl_localizations.g.dart';

class CatgirlAppLocalizations extends AppLocalizations
    with CatgirlLocalizationOverrides {
  CatgirlAppLocalizations(this.base);

  @override
  final AppLocalizations base;

  @override
  String get localeName => Intl.getCurrentLocale();
}

/// Mirrors the catgirl setting for code that reads [currentAppLocalizations]
/// outside a widget tree; the application keeps it in step with the provider.
bool catgirlModeEnabled = false;

/// Wraps [base] with catgirl copy while [catgirlModeEnabled] is set.
AppLocalizations catgirlAppLocalizationsOf(AppLocalizations base) =>
    catgirlModeEnabled ? CatgirlAppLocalizations(base) : base;

/// Install in place of `AppLocalizations.delegate`; swapping delegates never reloads.
class CatgirlLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const CatgirlLocalizationsDelegate({this.enabled = false});

  final bool enabled;

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = await AppLocalizations.delegate.load(locale);
    return enabled ? CatgirlAppLocalizations(localizations) : localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) =>
      old is CatgirlLocalizationsDelegate && old.enabled != enabled;
}
