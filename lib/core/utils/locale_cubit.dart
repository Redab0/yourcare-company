import 'dart:ui';

import 'package:cleaning_service_driver/core/storage/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';

class LocaleCubit extends Cubit<Locale> {
  final LocaleStorage storage;

  LocaleCubit({required Locale initial, required this.storage})
      : super(initial);

  void changeLocale(Locale locale) {
    if (AppLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode)) {
      emit(locale);
      storage.write(locale.languageCode); // persist
    }
  }
}
