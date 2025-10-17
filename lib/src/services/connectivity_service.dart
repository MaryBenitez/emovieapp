import 'dart:async';
import 'dart:io';

import 'package:emovieapp/src/imports/imports.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectionStatusController;

  Stream<bool> get connectionStatus {
    _connectionStatusController ??= StreamController<bool>.broadcast();
    return _connectionStatusController!.stream;
  }

  bool _isConnected = true;
  bool get isConnected {
    return _isConnected;
  }

  Future<void> initialize() async {
    
    // Verificación inicial forzada
    await checkConnectionNow();
    
    // Escuchar cambios de conectividad
    _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus();
    });
  }

  Future<bool> checkConnectionNow() async {
    try {
      // 1. Verificar conectividad básica
      final result = await _connectivity.checkConnectivity();
      
      if (result == ConnectivityResult.none) {
        _updateStatus(false);
        return false;
      }
      
      // 2. Verificar conexión REAL con ping a Google DNS
      final hasRealConnection = await _hasRealInternetConnection();
      
      _updateStatus(hasRealConnection);
      return hasRealConnection;
      
    } catch (e) {
      _updateStatus(false);
      return false;
    }
  }

  Future<bool> _hasRealInternetConnection() async {
    try {
      // Intentar conectar a Google DNS con timeout corto
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 3));
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _updateStatus(bool connected) {
    final oldStatus = _isConnected;
    _isConnected = connected;
    
    if (oldStatus != _isConnected) {
      _connectionStatusController?.add(_isConnected);
    } else {
    }
  }

  Future<void> _updateConnectionStatus() async {
    await checkConnectionNow();
  }

  void dispose() {
    _connectionStatusController?.close();
  }
}