import 'package:flutter/material.dart';

class MovieParticle {
  final IconData icon;
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double pulsePhase;

  MovieParticle({
    required this.icon,
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.pulsePhase,
  });
}

class ImageHelper {
  static const String _base = 'https://image.tmdb.org/t/p/';
  static String poster(String? path, {String size = 'w342'}) => (path == null || path.isEmpty) ? '' : '$_base$size$path';
  static String backdrop(String? path, {String size = 'w780'}) => (path == null || path.isEmpty) ? '' : '$_base$size$path';
}