import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

void saveLastRoute(String route) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('lastRoute', route);
}

void navigateToErrorScreen(String message, NavigationBloc navigationBloc) {
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

void openTrailer(BuildContext context, String url) async {
  try {
    final Uri uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      showNoTrailerDialog(context);
    }
  } catch (e) {
    showNoTrailerDialog(context);
  }
}

Future<void> handleRefresh(BuildContext context) async {
    
    // Mostrar toast
    showToastMessage(
      message: 'Actualizando películas...', 
      backgroundColor: AppColors.secondColor, 
      textColor: AppColors.whiteColor
    );

    // Recargar todas las películas
    context.read<MovieBloc>().add(const LoadAllMovies());
    
    // Esperar un poco para mostrar el refresh
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Toast de éxito
    showToastMessage(
      message: '¡Películas actualizadas!', 
      backgroundColor: AppColors.secondColor, 
      textColor: AppColors.whiteColor
    );
  }