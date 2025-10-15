import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

void saveLastRoute(String route) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastRoute', route);
}

void navigateToErrorScreen(String message, NavigationBloc navigationBloc) {
  debugPrint("🚨 Error - Navegando a pantalla de error: $message");
  navigationBloc.add(
    NavigateToPage(
      routeName: '/errorScreen',
      arguments: {
        'errorMessage': message,
        'onRetry': () {
          navigationBloc.add(const NavigateToPage(routeName: '/home'));
        },
      },
    ),
  );
}

// Metodo para mostrar un mensaje toast
void showToastMessage({
  required String message, 
  Toast toastLength = Toast.LENGTH_SHORT,
  required Color backgroundColor,
  required Color textColor,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: toastLength,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: 14.0,
  );
}
