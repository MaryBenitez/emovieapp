part of '../blocs/movie_bloc.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<LanguageModel> listLanguages;
  final List<MovieModel> upcomingMovies;
  final List<MovieModel> popularMovies;
  final List<MovieModel> trendingMovies;
  final List<MovieModel> recommendedMovies;
  final bool isLoadingRecommendations;

  const MovieLoaded({
    this.listLanguages = const [],
    this.upcomingMovies = const [],
    this.popularMovies = const [],
    this.trendingMovies = const [],
    this.recommendedMovies = const [],
    this.isLoadingRecommendations = false, 
  });

  MovieLoaded copyWith({
    List<LanguageModel>? listLanguages,
    List<MovieModel>? upcomingMovies,
    List<MovieModel>? popularMovies,
    List<MovieModel>? trendingMovies,
    List<MovieModel>? recommendedMovies,
    bool? isLoadingRecommendations,
  }) {
    return MovieLoaded(
      listLanguages: listLanguages ?? this.listLanguages,
      upcomingMovies: upcomingMovies ?? this.upcomingMovies,
      popularMovies: popularMovies ?? this.popularMovies,
      trendingMovies: trendingMovies ?? this.trendingMovies,
      recommendedMovies: recommendedMovies ?? this.recommendedMovies,
      isLoadingRecommendations: isLoadingRecommendations ?? this.isLoadingRecommendations,
    );
  }

  @override
  List<Object> get props => [
    listLanguages,
    upcomingMovies, 
    popularMovies, 
    trendingMovies,
    recommendedMovies,
    isLoadingRecommendations,
  ];
}

class MovieError extends MovieState {
  final String message;

  const MovieError({required this.message});

  @override
  List<Object> get props => [message];
}