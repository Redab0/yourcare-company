import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension LocalizationX on BuildContext {
  /// shortcut for AppLocalizations.of(this)!
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
