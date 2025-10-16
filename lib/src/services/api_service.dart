// ignore_for_file: unnecessary_type_check

import 'dart:async';
import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';

class ApiService {
  final Dio _dio;
  late SharedPreferences _prefs;
  late String _currentLanguage;
  final LanguageBloc languageBloc;
  final NavigationBloc navigationBloc;
  late final StreamSubscription languageSubscription;

  ApiService({
    required this.navigationBloc,
    required this.languageBloc,
  }) : _dio = Dio(BaseOptions(
          baseUrl: API.base, // TMDb
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    _initializeLanguage();
    _listenLanguageChanges();

    // Interceptor: agrega language/region y auth TMDb
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Idioma/Región por defecto
        final lang = _mapLang(_currentLanguage);     // 'es' -> 'es-ES'
        options.queryParameters.putIfAbsent('language', () => lang);
        options.queryParameters.putIfAbsent('region', () => 'ES'); // ajusta a tu público

        // Auth TMDb: v4 Bearer > v3 api_key
        if (Env.tmdbV4Token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${Env.tmdbV4Token}';
        } else if (Env.tmdbApiKey.isNotEmpty) {
          options.queryParameters.putIfAbsent('api_key', () => Env.tmdbApiKey);
        }

        handler.next(options);
      },
      onError: (e, h) => h.next(e),
    ));
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initializeLanguage();
  }

  Future<void> _initializeLanguage() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLang = _prefs.getString('languageCode');
    if (savedLang != null && savedLang.isNotEmpty) {
      _currentLanguage = savedLang;
    } else {
      final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _currentLanguage = deviceLang;
      await _prefs.setString('languageCode', deviceLang);
    }
    debugPrint("Idioma actual ApiService: $_currentLanguage");
  }

  void _listenLanguageChanges() {
    languageSubscription = languageBloc.stream.listen((state) {
      if (state is LanguageState) {
        _currentLanguage = state.locale.languageCode;
        debugPrint('🌍 Idioma actualizado: $_currentLanguage');
      }
    });
  }

  void dispose() => languageSubscription.cancel();

  String _mapLang(String code) {
    switch (code) {
      case 'es': return 'es-ES';
      case 'en': return 'en-US';
      case 'pt': return 'pt-BR';
      default:   return 'en-US';
    }
  }

  // Métodos HTTP (dejamos solo GET para TMDb; puedes conservar post/put/patch si quieres)
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (error) {
      return _handleError(error);
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    if (error is DioException) {
      final status = error.response?.statusCode ?? 500;
      String message;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = "Tiempo de conexión agotado";
          navigateToErrorScreen(message, navigationBloc);
          break;
        case DioExceptionType.badResponse:
          final raw = error.response?.data;
          message = raw is Map && raw['status_message'] != null
              ? raw['status_message']
              : "Error con código $status";
          break;
        case DioExceptionType.cancel:
          message = "Solicitud cancelada";
          break;
        case DioExceptionType.unknown:
        default:
          message = "Error inesperado: ${error.message}";
      }
      return {'statusCode': status, 'message': message};
    }
    return {'statusCode': 500, 'message': "Error inesperado: $error"};
  }
}
