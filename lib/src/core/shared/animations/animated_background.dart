import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final double opacity;
  final bool isVisible;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.opacity = 0.1,
    this.isVisible = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late AnimationController _particleController;
  List<MovieParticle> particles = [];

  @override
  void initState() {
    super.initState();

    // Controlador para iconos (mismo que en splash)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Crear iconos
    _createIcons();
  }

  // MISMA FUNCIÓN QUE EN SPLASH
  void _createIcons() {
    final random = math.Random();
    final count = 30; // Menos iconos para el home (menos denso)

    for (int i = 0; i < count; i++) {
      particles.add(MovieParticle(
        icon: _getRandomMovieIcon(),
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        velocityX: (random.nextDouble() - 0.5) * 0.3, // Más lento que splash
        velocityY: (random.nextDouble() - 0.5) * 0.3,
        size: 24.0 + random.nextDouble() * 24.0, // Más pequeños
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
        color: _getRandomIconColor(random),
        pulsePhase: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  // MISMA FUNCIÓN QUE EN SPLASH
  IconData _getRandomMovieIcon() {
    final icons = [
      Icons.movie,
      Icons.theaters,
      Icons.play_circle_outline,
      Icons.video_camera_back,
      Icons.camera_roll,
      Icons.local_movies,
      Icons.videocam,
      Icons.star,
      Icons.favorite_border,
      Icons.play_arrow,
      Icons.movie_filter,
      Icons.slow_motion_video,
    ];
    return icons[math.Random().nextInt(icons.length)];
  }

  // MISMA FUNCIÓN QUE EN SPLASH (pero más transparente)
  Color _getRandomIconColor(math.Random random) {
    final colors = [
      AppColors.secondColor.withOpacity(0.2),
      AppColors.whiteColor.withOpacity(0.15),
      AppColors.secondColor.withOpacity(0.1),
      AppColors.whiteColor.withOpacity(0.2),
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return widget.child;
    }

    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final scale = (shortest / 400.0).clamp(0.7, 1.6);

    return Stack(
      children: [
        // DEGRADADO DE FONDO (IGUAL QUE SPLASH)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryColor,
                AppColors.secondColor,
              ],
            ),
          ),
        ),

        // ICONOS FLOTANTES (EXACTO DEL SPLASH)
        if (widget.isVisible) ...[
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: IconPainter(
                    particles: particles,
                    animationValue: _particleController.value,
                    sizeFactor: scale,
                    excludeCenterWidth: 0,
                    excludeCenterHeight: 0,
                  ),
                ),
              );
            },
          ),
        ],

        // CONTENIDO PRINCIPAL
        widget.child,
      ],
    );
  }
}