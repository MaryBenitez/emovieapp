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
  final MovieDetailModel? currentMovieDetail;
  final VideosResponse? currentVideos;

  const MovieLoaded({
    required this.listLanguages,
    required this.upcomingMovies,
    required this.popularMovies,
    required this.trendingMovies,
    required this.recommendedMovies,
    required this.isLoadingRecommendations,
    this.currentMovieDetail,
    this.currentVideos,
  });

  @override
  List<Object> get props => [
    listLanguages,
    upcomingMovies,
    popularMovies,
    trendingMovies,
    recommendedMovies,
    isLoadingRecommendations,
    currentMovieDetail ?? Object(),
    currentVideos ?? Object(), 
  ];

  MovieLoaded copyWith({
    List<LanguageModel>? listLanguages,
    List<MovieModel>? upcomingMovies,
    List<MovieModel>? popularMovies,
    List<MovieModel>? trendingMovies,
    List<MovieModel>? recommendedMovies,
    bool? isLoadingRecommendations,
    MovieDetailModel? currentMovieDetail,
    VideosResponse? currentVideos, 
  }) {
    return MovieLoaded(
      listLanguages: listLanguages ?? this.listLanguages,
      upcomingMovies: upcomingMovies ?? this.upcomingMovies,
      popularMovies: popularMovies ?? this.popularMovies,
      trendingMovies: trendingMovies ?? this.trendingMovies,
      recommendedMovies: recommendedMovies ?? this.recommendedMovies,
      isLoadingRecommendations: isLoadingRecommendations ?? this.isLoadingRecommendations,
      currentMovieDetail: currentMovieDetail ?? this.currentMovieDetail,
      currentVideos: currentVideos ?? this.currentVideos,
    );
  }
}

// Detalle
class MovieDetailWithVideosLoaded extends MovieState {
  final MovieDetailModel movieDetail;
  final VideosResponse videosResponse;

  const MovieDetailWithVideosLoaded({
    required this.movieDetail,
    required this.videosResponse,
  });

  @override
  List<Object> get props => [movieDetail, videosResponse];
}

class MovieError extends MovieState {
  final String message;

  const MovieError({required this.message});

  @override
  List<Object> get props => [message];
}

class MovieDetailLoaded extends MovieState {
  final MovieDetailModel movieDetail;

  const MovieDetailLoaded({required this.movieDetail});

  @override
  List<Object> get props => [movieDetail];
}

class MovieDetailError extends MovieState {
  final String message;

  const MovieDetailError({required this.message});

  @override
  List<Object> get props => [message];
}

class MovieVideosLoaded extends MovieState {
  final VideosResponse videosResponse;

  const MovieVideosLoaded({required this.videosResponse});

  @override
  List<Object> get props => [videosResponse];
}

class MovieVideoError extends MovieState {
  final String message;

  const MovieVideoError({required this.message});

  @override
  List<Object> get props => [message];
}