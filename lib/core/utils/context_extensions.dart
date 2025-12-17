import 'package:cleaning_service_driver/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension LocalizationX on BuildContext {
  /// shortcut for AppLocalizations.of(this)!
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Generic user-facing error message (localized English/Arabic)
  String get genericErrorMessage =>
      l10n.localeName.startsWith('ar') ? 'حصل خطأ ما' : 'Something went wrong';
}
