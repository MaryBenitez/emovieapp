part of '../blocs/language_bloc.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();
}

class ChangeLanguageEvent extends LanguageEvent {
  final Locale locale;

  const ChangeLanguageEvent(this.locale);

  @override
  List<Object> get props => [locale];
}