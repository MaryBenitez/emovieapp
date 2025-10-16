import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Controladores de animación:
  late AnimationController _textController; // maneja la entrada del texto (appear + scale + tracking)
  late AnimationController _particleController; // anima la posición/rotación de los íconos flotantes
  late AnimationController _glowController; // oscila la intensidad del glow en el texto
  
   // Tweens/Animations derivados de _textController/_glowController
  late Animation<double> _textOpacity;    // 0 → 1
  late Animation<double> _textScale;      // 0.5 → 1.0 (con elasticOut)
  late Animation<double> _letterSpacing;  // 10 → 1.2 (tracking)
  late Animation<double> _glowAnimation;  // 0.3 ↔ 1.0 (pulso del glow)
  
  // Estado de los íconos flotantes
  List<MovieParticle> particles = [];

  NavigationBloc navigationBloc = NavigationBloc();

  @override
  void initState() {
    super.initState();
    
    // Controlador para el texto
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Controlador para iconos
    // Período largo para que el movimiento sea suave/continuo
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Controlador para el brillo del texto
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Animaciones del texto
    // Opacidad: entra entre 30% y 80% del timeline del _textController
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController, 
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut)
      ),
    );

    // Escala: comienza chico y salta con elasticOut
    _textScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController, 
        curve: const Interval(0.2, 0.9, curve: Curves.elasticOut)
      ),
    );

    // Tracking: abre y cierra el espaciado de letras (efecto “cinemático”)
    _letterSpacing = Tween<double>(begin: 10, end: 1.2).animate(
      CurvedAnimation(
        parent: _textController, 
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)
      ),
    );

    // Glow del texto: se usa como factor de opacidad en sombras
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Crear iconos
    _createIcons();
    
    // Iniciar animaciones
    _textController.forward();

    // Navegar después de la animación
    if (mounted) {
      context.read<SplashBloc>().add(CheckAuthentication(navigationBloc: navigationBloc));
    }

  }

  // Crea la “nube” de íconos con posiciones aleatorias
  // Cada ícono tiene su propia velocidad, rotación, color y tamaño base
  void _createIcons() {
    final random = math.Random();

    // Cantidad
    final count = 50;

    for (int i = 0; i < count; i++) {
      particles.add(MovieParticle(
        icon: _getRandomMovieIcon(),
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        velocityX: (random.nextDouble() - 0.5) * 0.5,
        velocityY: (random.nextDouble() - 0.5) * 0.5,
        size: 36.0 + random.nextDouble() * 36.0,
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.03,
        color: _getRandomIconColor(random),
        pulsePhase: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  // Selección aleatoria de íconos relacionados con cine/video.
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

  // Paleta de colores para los íconos
  Color _getRandomIconColor(math.Random random) {
    final colors = [
      AppColors.secondColor.withOpacity(0.6),
      AppColors.whiteColor.withOpacity(0.4),
      AppColors.secondColor.withOpacity(0.3),
      AppColors.whiteColor.withOpacity(0.6),
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _textController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // NEW: Responsivo — calculamos un factor de escala usando el lado más corto.
    //      400px => 1.0; limitamos el rango para evitar exageraciones en tablets.
    final shortest = MediaQuery.sizeOf(context).shortestSide; // NEW
    final scale = (shortest / 400.0).clamp(0.7, 1.6);         // NEW

    // NEW: Derivamos tamaños en función de 'scale' para texto y sombras.
    final titleFontSize = (60.0 * scale).clamp(36.0, 96.0);   // NEW
    final blur1 = 15.0 * scale;                                // NEW
    final blur2 = 25.0 * scale;                                // NEW

    // NEW: Área central a despejar de íconos (estimada en función del tamaño del título).
    final textAreaWidth = titleFontSize * 5.2;   // NEW
    final textAreaHeight = titleFontSize * 1.6;  // NEW

    return Scaffold(
      body: Container(
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
        child: Stack(
          children: [
            // Iconos flotantes
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return Positioned.fill(
                  child: CustomPaint(
                    painter: IconPainter(
                      particles: particles,
                      animationValue: _particleController.value,
                      // NEW: pasamos factor de escala y área a excluir para que el painter sea responsivo
                      sizeFactor: scale, 
                      excludeCenterWidth: textAreaWidth,
                      excludeCenterHeight: textAreaHeight,
                    ),
                  ),
                );
              },
            ),
            
            // Texto principal
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_textController, _glowController]),
                builder: (context, _) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.scale(
                      scale: _textScale.value,
                      child: Text(
                        'eMovie',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize, // NEW: antes fijo en 60
                          fontWeight: FontWeight.bold,
                          letterSpacing: _letterSpacing.value,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: blur1, // NEW: antes 15
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              color: AppColors.secondColor.withOpacity(_glowAnimation.value * 0.3),
                              blurRadius: blur2, // NEW: antes 25
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        // Texto "Iniciando..."
                        Text(
                          'Iniciando...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Contenedor de la barra de progreso
                        Container(
                          width: 250 * scale,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: AnimatedBuilder(
                            animation: _particleController,
                            builder: (context, child) {
                              // Progreso basado en el tiempo (8 segundos del SplashBloc)
                              final progress = (_particleController.value * 0.8).clamp(0.0, 1.0);
                              
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: (250 * scale) * progress,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    // gradient: LinearGradient(
                                    //   colors: [
                                    //     AppColors.secondColor,
                                    //     Colors.white,
                                    //     AppColors.secondColor,
                                    //   ],
                                    //   stops: const [0.0, 0.5, 1.0],
                                    // ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondColor.withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Indicador de porcentaje
                        AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            final percentage = ((_particleController.value * 80).clamp(0.0, 80.0)).round();
                            return Text(
                              '$percentage%',
                              style: TextStyle(
                                color: AppColors.secondColor.withOpacity(0.8),
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}