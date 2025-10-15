part of '../blocs/language_bloc.dart';

class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState(this.locale);

  @override
  List<Object> get props => [locale];
}

// Estado para mostrar que se está cargando el idioma
class LanguageStateLoading extends LanguageState {
  const LanguageStateLoading() : super(const Locale('es'));
}