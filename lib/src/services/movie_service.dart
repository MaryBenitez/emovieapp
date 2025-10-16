import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';

class MovieService {
  final ApiService _apiService;

  MovieService({required ApiService apiService}) : _apiService = apiService;

  List<MovieModel> listMoviesUpcoming = [];
  List<MovieModel> listMoviesPopular = [];
  List<MovieModel> listMoviesRecommended = [];
  MovieDetailModel resMovieDetails = MovieDetailModel();

  // Proximos estrenos
  Future<List<MovieModel>> getMoviesUpcoming() async {
    try {
      final response = await _apiService.get(API.upcoming());
      final Map<String, dynamic> responseMap = response as Map<String, dynamic>;
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
      debugPrint('getUpcoming Error :: $e');
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
    try {
      final response = await _apiService.get(API.popular());
      final Map<String, dynamic> responseMap = response as Map<String, dynamic>;
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
      debugPrint('getMoviesPopular Error :: $e');
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
    int? year, // Filtro de año
    String period = 'day', // Filtro de período (day/week)
  }) async {
    try {
      // Asignar el año actual si year es null
      year ??= DateTime.now().year;

      // Validar período
      if (period != 'day' && period != 'week') {
        period = 'day'; // Default a week si es inválido
      }

      // Construir query parameters
      final queryParams = API.trendingQuery(
        language: language,
        year: year,
      );
      
      final response = await _apiService.get(
        API.trending(period),
        queryParameters: queryParams
      );
      
      final Map<String, dynamic> responseMap = response as Map<String, dynamic>;
      final modelResponse = GeneralModel<List<dynamic>>.fromMap(responseMap);
      
      if (modelResponse.success == false && modelResponse.results == null) {
        showToastMessage(
          message: modelResponse.statusMessage ?? 'Error cargando recomendaciones', 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        return [];
      }

      final List<dynamic> resultsData = modelResponse.results ?? [];
      final List<MovieModel> trendingMovies = resultsData
          .map((movieJson) => MovieModel.fromMap(movieJson as Map<String, dynamic>))
          .toList();

      // LIMITAR A 6 PELÍCULAS
      return trendingMovies.take(6).toList();
      
    } catch (e) {
      debugPrint('getTrendingForRecommendations Error :: $e');
      showToastMessage(
        message: 'Error fetching getTrendingForRecommendations: $e', 
        backgroundColor: AppColors.redColor, 
        textColor: AppColors.whiteColor
      );
      return [];
    }
  }

  // Detalle de peliculas
  Future<MovieDetailModel?> getMoviesDetails({required int idMovie}) async {
    try {
      final response = await _apiService.get(API.detailsMovie(idMovie));
      
      if (response == null) {
        showToastMessage(
          message: 'No se recibió respuesta del servidor', 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
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
        return null;
      }

      // Validar que tenga los campos mínimos requeridos
      if (!responseMap.containsKey('id') || responseMap['id'] == null) {
        showToastMessage(
          message: 'Respuesta inválida del servidor', 
          backgroundColor: AppColors.redColor, 
          textColor: AppColors.whiteColor
        );
        return null;
      }

      // Crear el modelo directamente desde el responseMap
      final movieDetail = MovieDetailModel.fromJson(responseMap);
      
      return movieDetail;
      
    } catch (e) {
      debugPrint('getMoviesDetails Error :: $e');
      showToastMessage(
        message: 'Error fetching getMoviesDetails: ${e.toString()}', 
        backgroundColor: AppColors.redColor, 
        textColor: AppColors.whiteColor
      );
      return null;
    }
  }

}