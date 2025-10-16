part of '../blocs/movie_bloc.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<MovieModel> upcomingMovies;
  final List<MovieModel> popularMovies;
  final List<MovieModel> trendingMovies;

  const MovieLoaded({
    this.upcomingMovies = const [],
    this.popularMovies = const [],
    this.trendingMovies = const [],
  });

  @override
  List<Object> get props => [upcomingMovies, popularMovies, trendingMovies];
}

class MovieError extends MovieState {
  final String message;

  const MovieError({required this.message});

  @override
  List<Object> get props => [message];
}