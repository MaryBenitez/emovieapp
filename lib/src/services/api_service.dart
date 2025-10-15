// ignore_for_file: unnecessary_type_check

import 'dart:async';
import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;
  late SharedPreferences _prefs;
  late String _currentLanguage;
  final LanguageBloc languageBloc;
  final NavigationBloc navigationBloc;
  late final StreamSubscription languageSubscription;
  API api = API();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initializeLanguage();
  }

  ApiService({
    required this.navigationBloc,
    required this.languageBloc,
  })
      : baseUrl = API.baseURL,
        _dio = Dio(BaseOptions(
          baseUrl: API.baseURL,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
          },
        )) {
    _initializeLanguage();
    _listenLanguageChanges();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.path == API.refreshToken || options.path == API.signIn) {
          // Ignora las solicitudes de renovación
          handler.next(options);
          return;
        }

        final token = _prefs.getString('accessToken');
        options.headers['accept-language'] = _currentLanguage;
        if (options.extra['isAuth'] == true && token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        final isLoginCall = error.requestOptions.path == API.signIn;
        final requiresAuth = error.requestOptions.extra['isAuth'] == true;
        if (error.response?.statusCode == 401 && requiresAuth && !isLoginCall) {
          
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _initializeLanguage() async {
    _prefs = await SharedPreferences.getInstance();

    final savedLang = _prefs.getString('languageCode');

    if (savedLang != null && savedLang.isNotEmpty) {
      _currentLanguage = savedLang;
    } else {
      final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _currentLanguage = deviceLang;
      await _prefs.setString('languageCode', deviceLang); // Guardamos por si se necesita luego
    }

    debugPrint("Idioma actual configurado en ApiService: $_currentLanguage");
  }

  void _listenLanguageChanges() {
    languageSubscription = languageBloc.stream.listen((state) {
      if (state is LanguageState) {
        _currentLanguage = state.locale.languageCode;
        debugPrint('🌍 Idioma actualizado: $_currentLanguage');
      }
    });
  }

  void dispose() {
    languageSubscription.cancel();
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool isAuth = false,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: {
            ...?headers, // Combina los encabezados personalizados
            if (isAuth) 'Authorization': 'Bearer ${_prefs.getString('accessToken')}',
          },
          extra: {'isAuth': isAuth},
        ),
      );
      if (response.statusCode == 401) {
        
      }
      return response.data;
    } catch (error) {
      return _handleError(error);
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool isAuth = false,
    bool isMultipart = false,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: isMultipart ? FormData.fromMap(data!) : data,
        options: Options(
          contentType: isMultipart ? 'multipart/form-data' : 'application/json',
          headers: {
            ...?headers, // Combina los encabezados personalizados
            if (isAuth) 'Authorization': 'Bearer ${_prefs.getString('accessToken')}',
          },
          extra: {'isAuth': isAuth},
        ),
      );
      if (response.statusCode == 401) {
        
      }
      return response.data;
    } catch (error) {
      return _handleError(error);
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool isAuth = false,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(
          headers: {
            ...?headers, // Combina los encabezados personalizados
            if (isAuth) 'Authorization': 'Bearer ${_prefs.getString('accessToken')}',
          },
          extra: {'isAuth': isAuth},
        ),
      );
      if (response.statusCode == 401) {
        
      }
      return response.data;
    } catch (error) {
      return _handleError(error);
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool isAuth = false,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        options: Options(
          headers: {
            ...?headers, // Combina los encabezados personalizados
            if (isAuth) 'Authorization': 'Bearer ${_prefs.getString('accessToken')}',
          },
          extra: {'isAuth': isAuth},
        ),
      );
      if (response.statusCode == 401) {
        
      }
      return response.data;
    } catch (error) {
      return _handleError(error);
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    bool isAuth = false,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        options: Options(
          headers: {
            ...?headers,
            if (isAuth) 'Authorization': 'Bearer ${_prefs.getString('accessToken')}',
          },
          extra: {'isAuth': isAuth},
        ),
      );
      if (response.statusCode == 401) {
        
      }
      return response.data;
    } catch (error) {
      return _handleError(error);
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    if (error is DioException) {
      int statusCode = error.response?.statusCode ?? 500;
      String message;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = "Tiempo de conexión agotado";
          navigateToErrorScreen(message, navigationBloc);
          break;

        case DioExceptionType.badResponse:
          final rawMessage = error.response?.data['message'];
          if (rawMessage is String) {
            message = rawMessage;
          } else if (rawMessage is List) {
            message = rawMessage.join(', ');
          } else {
            message = "Error desconocido con código $statusCode";
          }
          break;

        case DioExceptionType.cancel:
          message = "Solicitud cancelada";
          break;

        case DioExceptionType.unknown:
        default:
          message = "Error inesperado: ${error.message}";
      }

      return {
        'statusCode': statusCode,
        'message': message,
      };
    } else {
      return {
        'statusCode': 500,
        'message': "Error inesperado: $error",
      };
    }
  }
}
