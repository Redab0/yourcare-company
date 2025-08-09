import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  void changeLocale(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)) {
      emit(locale);
    }
  }
}
