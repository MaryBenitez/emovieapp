import 'package:emovieapp/src/imports/imports.dart';

class MovieService {
  final ApiService _apiService;
  final CacheService _cache;
  final ConnectivityService _connectivityService = ConnectivityService(); 

  MovieService({required ApiService apiService, required CacheService cache})
		: _apiService = apiService,
		  _cache = cache;

  List<MovieModel> listMoviesUpcoming = [];
  List<MovieModel> listMoviesPopular = [];
  List<MovieModel> listMoviesRecommended = [];
  MovieDetailModel resMovieDetails = MovieDetailModel();

  // TTL por sección (minutos)
	static const int _ttlUpcoming = 120;
	static const int _ttlPopular  = 90;
	static const int _ttlTrending = 60;
	static const int _ttlDetails  = 180;
	static const int _ttlVideos   = 180;

  // Helpers de clave de caché (evita colisiones entre parámetros)
	String _kUpcoming() => 'upcoming';
	String _kPopular()  => 'popular';
	String _kTrending({required String period, required String language, required int year}) => 'trending:$period:l=$language:y=$year';
	String _kDetails(int id, String language) => 'movie:$id:details:l=$language';
	String _kVideos(int id, String language)  => 'movie:$id:videos:l=$language';

  // Proximos estrenos
  Future<List<MovieModel>> getMoviesUpcoming() async {
    final cacheKey = _kUpcoming();

    final isConnected = await _connectivityService.checkConnectionNow();
    if (!isConnected) {
      final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlUpcoming);
      if (cached != null && cached['results'] is List) {
        return (cached['results'] as List)
            .map((e) => MovieModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      final response = await _apiService.get(API.upcoming());
      final Map<String, dynamic> responseMap = response as Map<String, dynamic>;
      // Guarda caché si la respuesta parece válida
      if (responseMap['results'] is List) {
				await _cache.setJson(cacheKey, responseMap);
			}
      final modelResponse = GeneralModel<List<dynamic>>.fromMap(responseMap);
      
      if (modelResponse.success == false && modelResponse.results == null) {
        showToastMessage(
          message: modelResponse.statusMessage ?? 'Error desconocido', 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        return [];
      }

      // Procesar los resultados correctamente
      final List<dynamic> resultsData = modelResponse.results ?? [];
      final List<MovieModel> listMoviesUpcoming = resultsData.map((movieJson) => MovieModel.fromMap(movieJson as Map<String, dynamic>)).toList();

      return listMoviesUpcoming;
    } catch (e) {
      // Falla de red → prueba caché
			final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlUpcoming);
			if (cached != null && cached['results'] is List) {
				final List<MovieModel> listMoviesUpcoming = (cached['results'] as List)
					.map((e) => MovieModel.fromMap(e as Map<String, dynamic>))
					.toList();
				return listMoviesUpcoming;
			}
      showToastMessage(
        message: 'Error fetching getMoviesUpcoming: $e', 
        backgroundColor: AppColors.redColor, 
        textColor: AppColors.whiteColor
      );
      return [];
    }
  }

  // Populares
  Future<List<MovieModel>> getMoviesPopular() async {
    final cacheKey = _kPopular();

    final isConnected = await _connectivityService.checkConnectionNow();
    if (!isConnected) {
      final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlPopular);
      if (cached != null && cached['results'] is List) {
        return (cached['results'] as List)
            .map((e) => MovieModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    try {
      final response = await _apiService.get(API.popular());
      final Map<String, dynamic> responseMap = response as Map<String, dynamic>;
      if (responseMap['results'] is List) {
				await _cache.setJson(cacheKey, responseMap);
			}
      final modelResponse = GeneralModel<List<dynamic>>.fromMap(responseMap);
      
      if (modelResponse.success == false && modelResponse.results == null) {
        showToastMessage(
          message: modelResponse.statusMessage ?? 'Error desconocido', 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        return [];
      }

      // Procesar los resultados correctamente
      final List<dynamic> resultsData = modelResponse.results ?? [];
      final List<MovieModel> listMoviesPopular = resultsData.map((movieJson) => MovieModel.fromMap(movieJson as Map<String, dynamic>)).toList();

      return listMoviesPopular;
    } catch (e) {
      final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlPopular);
			if (cached != null && cached['results'] is List) {
				final List<MovieModel> listMoviesPopular = (cached['results'] as List)
					.map((e) => MovieModel.fromMap(e as Map<String, dynamic>))
					.toList();
				return listMoviesPopular;
			}
      showToastMessage(
        message: 'Error fetching getMoviesPopular: $e', 
        backgroundColor: AppColors.redColor, 
        textColor: AppColors.whiteColor
      );
      return [];
    }
  }

  // Recomendaciones
  Future<List<MovieModel>> getTrendingForRecommendations({
		String? language = 'es-ES', // Filtro de idioma por defecto
		int? year,                  // Filtro de año
		String period = 'day',      // Filtro de período (day/week)
	}) async {

		try {
			year ??= DateTime.now().year;
			if (period != 'day' && period != 'week') {
				period = 'day';
			}

			final cacheKey = _kTrending(period: period, language: language ?? 'es-ES', year: year);

      final isConnected = await _connectivityService.checkConnectionNow();
      if (!isConnected) {
        final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlTrending);
        if (cached != null && cached['results'] is List) {
          final List<MovieModel> trendingMovies = (cached['results'] as List)
              .map((e) => MovieModel.fromMap(e as Map<String, dynamic>))
              .toList();
          return trendingMovies.take(6).toList();
        }
        return [];
      }

			try {
				// RED
				final queryParams = API.trendingQuery(
					language: language,
					year: year,
				);

				final response = await _apiService.get(
					API.trending(period),
					queryParameters: queryParams,
				);

				final Map<String, dynamic> responseMap = response as Map<String, dynamic>;

				// Guarda caché si hay results
				if (responseMap['results'] is List) {
					await _cache.setJson(cacheKey, responseMap);
				}

				final modelResponse = GeneralModel<List<dynamic>>.fromMap(responseMap);

				if (modelResponse.success == false && modelResponse.results == null) {
					showToastMessage(
						message: modelResponse.statusMessage ?? 'Error cargando recomendaciones',
						backgroundColor: AppColors.redColor,
						textColor: AppColors.whiteColor,
					);
					return [];
				}

				final List<dynamic> resultsData = modelResponse.results ?? [];
				final List<MovieModel> trendingMovies = resultsData
					.map((movieJson) => MovieModel.fromMap(movieJson as Map<String, dynamic>))
					.toList();

				return trendingMovies.take(6).toList();
			} catch (_) {
				// OFFLINE / error → caché
				final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlTrending);
				if (cached != null && cached['results'] is List) {
					final List<MovieModel> trendingMovies = (cached['results'] as List).map((e) => MovieModel.fromMap(e as Map<String, dynamic>)).toList();
					return trendingMovies.take(6).toList();
				}
				rethrow;
			}
		} catch (e) {
			showToastMessage(
				message: 'Error fetching getTrendingForRecommendations: $e',
				backgroundColor: AppColors.redColor,
				textColor: AppColors.whiteColor,
			);
			return [];
		}
	}

  // Detalle de peliculas
  Future<MovieDetailModel?> getMoviesDetails({required int idMovie}) async {
    final language = 'es-ES';
		final cacheKey = _kDetails(idMovie, language);

    final isConnected = await _connectivityService.checkConnectionNow();
    if (!isConnected) {
      final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlDetails);
      return cached != null ? MovieDetailModel.fromJson(cached) : null;
    }

    try {
      final response = await _apiService.get(API.detailsMovie(idMovie));
      
      if (response == null) {
        showToastMessage(
          message: 'No se recibió respuesta del servidor', 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        // Intentar caché
				final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlDetails);
				if (cached != null) return MovieDetailModel.fromJson(cached);
				return null;
      }

      final Map<String, dynamic> responseMap = response as Map<String, dynamic>;
      
      // Validar si hay errores en la respuesta
      if (responseMap.containsKey('success') && responseMap['success'] == false) {
        final errorMessage = responseMap['status_message'] ?? 'Error desconocido';
        showToastMessage(
          message: errorMessage, 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        // Intentar caché
				final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlDetails);
				if (cached != null) return MovieDetailModel.fromJson(cached);
				return null;
      }

      // Validar que tenga los campos mínimos requeridos
      if (!responseMap.containsKey('id') || responseMap['id'] == null) {
        showToastMessage(
          message: 'Respuesta inválida del servidor', 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        // Intentar caché
				final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlDetails);
				if (cached != null) return MovieDetailModel.fromJson(cached);
				return null;
      }

      // Guarda caché y retorna
			await _cache.setJson(cacheKey, responseMap);
			final movieDetail = MovieDetailModel.fromJson(responseMap);
			return movieDetail;
      
    } catch (e) {
      final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlDetails);
			if (cached != null) return MovieDetailModel.fromJson(cached);

      showToastMessage(
        message: 'Error fetching getMoviesDetails: ${e.toString()}', 
        backgroundColor: AppColors.redColor, 
        textColor: AppColors.whiteColor
      );
      return null;
    }
  }

  Future<VideosResponse?> getMovieVideos({required int movieId}) async {
    final language = 'es-ES';
		final cacheKey = _kVideos(movieId, language);

    final isConnected = await _connectivityService.checkConnectionNow();
    if (!isConnected) {
      final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlVideos);
      return cached != null ? VideosResponse.fromJson(cached) : null;
    }

    try {
      final response = await _apiService.get(API.videoMovie(movieId));

      if (response == null) {
        showToastMessage(
          message: 'No se recibió respuesta del servidor', 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        // Intentar caché
				final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlVideos);
				if (cached != null) return VideosResponse.fromJson(cached);
				return null;
      }
      
      final Map<String, dynamic> responseMap = response as Map<String, dynamic>;
      
      // Validar si hay errores en la respuesta
      if (responseMap.containsKey('success') && responseMap['success'] == false) {
        final errorMessage = responseMap['status_message'] ?? 'Error desconocido';
        showToastMessage(
          message: errorMessage, 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        // Intentar caché
				final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlVideos);
				if (cached != null) return VideosResponse.fromJson(cached);
				return null;
      }

      // Guarda caché y retorna
			await _cache.setJson(cacheKey, responseMap);
			final movieVideo = VideosResponse.fromJson(responseMap);
			return movieVideo;
    } catch (e) {
      final cached = await _cache.getJson(cacheKey, ttlMinutes: _ttlVideos);
			if (cached != null) return VideosResponse.fromJson(cached);

      showToastMessage(
        message: 'Error cargando videos: ${e.toString()}', 
        backgroundColor: AppColors.redColor, 
        textColor: AppColors.whiteColor
      );
      return null;
    }
  }

}