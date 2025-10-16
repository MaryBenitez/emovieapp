part of '../blocs/movie_bloc.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

// ✅ Un solo evento para cargar todo
class LoadAllMovies extends MovieEvent {
  const LoadAllMovies();
}