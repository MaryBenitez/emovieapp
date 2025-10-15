import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

part '../events/language_event.dart';
part '../states/language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String languageKey = 'selected_language_code';

  LanguageBloc() : super(const LanguageStateLoading()) {
    on<ChangeLanguageEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(languageKey, event.locale.languageCode);
      emit(LanguageState(event.locale));
    });

    _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(languageKey) ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    add(ChangeLanguageEvent(Locale(savedLanguageCode))); // Dispatch event to update state
  }
}