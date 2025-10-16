import 'package:emovieapp/src/imports/imports.dart';

part '../events/movie_event.dart';
part '../states/movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieService _movieService;

  MovieBloc({required MovieService movieService}) 
    : _movieService = movieService,
      super(MovieInitial()) {
    
    // ✅ Un solo evento que carga todo
    on<LoadAllMovies>((event, emit) async {
      emit(MovieLoading());
      try {
        // Cargar todas las películas en paralelo
        final results = await Future.wait([
          _movieService.getMoviesUpcoming(),
          _movieService.getMoviesPopular(), 
          // _movieService.getTrending(), // Futuro
        ]);
        
        emit(MovieLoaded(
          upcomingMovies: results[0],
          popularMovies: results.length > 1 ? results[1] : [],
          // trendingMovies: results.length > 2 ? results[2] : [],
        ));
      } catch (e) {
        emit(MovieError(message: e.toString()));
      }
    });
  }
}