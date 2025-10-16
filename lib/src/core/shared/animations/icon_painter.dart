import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class IconPainter extends CustomPainter {
  final List<MovieParticle> particles;
  final double animationValue;

  // Pparámetros para responsividad y área excluida del centro
  final double sizeFactor;          // factor de escala del viewport
  final double excludeCenterWidth;  // ancho a despejar alrededor del título
  final double excludeCenterHeight; // alto a despejar alrededor del título

  IconPainter({
    required this.particles,
    required this.animationValue,
    required this.sizeFactor,        
    required this.excludeCenterWidth,
    required this.excludeCenterHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final p in particles) {
      // posición base + drift senoidal
      double baseX = p.startX + p.velocityX * animationValue * 5;
      double baseY = p.startY + p.velocityY * animationValue * 5;

      // mantén dentro del [0,1]
      baseX = baseX.clamp(0.0, 1.0);
      baseY = baseY.clamp(0.0, 1.0);

      final x = baseX * size.width;
      final y = baseY * size.height;

      // Aamplitud de flote escalada por sizeFactor (más pantalla ⇒ más movimiento)
      final ampX = 30.0 * sizeFactor;
      final ampY = 20.0 * sizeFactor;
      final floatX = x + math.sin(animationValue * 2 * math.pi + p.pulsePhase) * ampX;
      final floatY = y + math.cos(animationValue * 2 * math.pi + p.pulsePhase) * ampY;

      // evita solapar el texto central
      final outsideText =
          floatX < centerX - excludeCenterWidth ||  
          floatX > centerX + excludeCenterWidth ||
          floatY < centerY - excludeCenterHeight || 
          floatY > centerY + excludeCenterHeight;

      if (!outsideText) continue;

      // tamaño
      final fontSize = (p.size * sizeFactor) * (0.8 + 0.4 * math.sin(animationValue * 4 * math.pi + p.pulsePhase));

      // Pinta el IconData como glyph con TextPainter
      final glyph = String.fromCharCode(p.icon.codePoint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: glyph,
          style: TextStyle(
            fontFamily: p.icon.fontFamily,
            package: p.icon.fontPackage,
            fontSize: fontSize,
            color: p.color,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      final rotation = p.rotation + p.rotationSpeed * animationValue * 100;

      canvas.save();
      canvas.translate(floatX, floatY);
      canvas.rotate(rotation);

      // centrar el glyph en (0,0)
      final dx = -textPainter.width / 2;
      final dy = -textPainter.height / 2;
      textPainter.paint(canvas, Offset(dx, dy));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant IconPainter oldDelegate) =>
      oldDelegate.particles != particles ||
      oldDelegate.animationValue != animationValue ||
      oldDelegate.sizeFactor != sizeFactor ||                
      oldDelegate.excludeCenterWidth != excludeCenterWidth ||
      oldDelegate.excludeCenterHeight != excludeCenterHeight;
}
