import 'package:emovieapp/src/imports/imports.dart';

part '../events/movie_event.dart';
part '../states/movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieService _movieService;
  final ConfigService _configService;

  MovieBloc({required MovieService movieService, required ConfigService configService}) 
    : _movieService = movieService,
      _configService = configService,
      super(MovieInitial()) {
    
    // Evento que carga todo
    on<LoadAllMovies>((event, emit) async {
      emit(MovieLoading());
      try {
        // Cargar todas las películas en paralelo
        final results = await Future.wait([
          _configService.getPrimaryLanguages(),
          _movieService.getMoviesUpcoming(),
          _movieService.getMoviesPopular(), 
          _movieService.getTrendingForRecommendations(),
        ]);
        
        emit(MovieLoaded(
          listLanguages: results[0] as List<LanguageModel>,
          upcomingMovies: results[1] as List<MovieModel>,
          popularMovies: results.length > 1 ? results[2] as List<MovieModel> : [],
          trendingMovies: results.length > 2 ? results[3] as List<MovieModel> : [],
          recommendedMovies: results[3] as List<MovieModel>,
          isLoadingRecommendations: false,
        ));
      } catch (e) {
        emit(MovieError(message: e.toString()));
      }
    });

    // Maneja filtro
    on<LoadRecommendationsWithFilter>((event, emit) async {
      if (state is MovieLoaded) {
        final currentState = state as MovieLoaded;
        
        // Mostrar loading en recomendaciones
        emit(currentState.copyWith(isLoadingRecommendations: true));
        
        try {
          final recommendations = await _movieService.getTrendingForRecommendations(
            language: event.language,
            year: event.year,
          );
          
          // Actualizar solo las recomendaciones
          emit(currentState.copyWith(
            recommendedMovies: recommendations,
            isLoadingRecommendations: false,
          ));
        } catch (e) {
          // En caso de error, quitar loading pero mantener datos anteriores
          emit(currentState.copyWith(isLoadingRecommendations: false));
        }
      }
    });

    on<LoadMovieDetail>((event, emit) async {
      emit(MovieLoading());
      try {
        final movieDetail = await _movieService.getMoviesDetails(idMovie: event.movieId);
        if (movieDetail != null) {
          emit(MovieDetailLoaded(movieDetail: movieDetail));
        } else {
          emit(const MovieDetailError(message: 'No se pudo cargar el detalle de la película'));
        }
      } catch (e) {
        emit(MovieDetailError(message: e.toString()));
      }
    });
  }
}