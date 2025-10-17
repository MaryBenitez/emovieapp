import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';

Future<bool> showExitDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        '¿Salir de la app?',
        style: TextStyle(
          color: AppColors.whiteColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        '¿Estás seguro de que quieres salir?',
        style: TextStyle(
          color: AppColors.whiteColor.withOpacity(0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: AppColors.whiteColor.withOpacity(0.7),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Salir',
            style: TextStyle(
              color: AppColors.secondColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  ) ?? false;
}

void showNoTrailerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        'Trailer no disponible',
        style: TextStyle(
          color: AppColors.whiteColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Lo sentimos, no se pudo abrir el trailer.',
        style: TextStyle(
          color: AppColors.whiteColor.withOpacity(0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'OK',
            style: TextStyle(
              color: AppColors.secondColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}