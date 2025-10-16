import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';

class MovieService {
  final ApiService _apiService;

  MovieService({required ApiService apiService}) : _apiService = apiService;

  List<MovieModel> listMoviesUpcoming = [];
  List<MovieModel> listMoviesPopular = [];
  List<MovieModel> listMoviesRecommended = [];

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

}