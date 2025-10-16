part of '../blocs/movie_bloc.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

// Cargar todo
class LoadAllMovies extends MovieEvent {
  const LoadAllMovies();
}

class LoadRecommendationsWithFilter extends MovieEvent {
  final String? language;
  final int? year;
  final String? period; 

  const LoadRecommendationsWithFilter({this.language, this.year, this.period});

  @override
  List<Object> get props => [language ?? '', year ?? 0, period ?? ''];
}

class UpdatePeriodFilter extends FilterEvent {
  final String period;

  const UpdatePeriodFilter({required this.period});

  @override
  List<Object> get props => [period];
}