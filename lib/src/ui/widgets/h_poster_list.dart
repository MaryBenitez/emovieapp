import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

typedef PosterTap<T> = void Function(T item);

class HPooterList<T> extends StatelessWidget {
  const HPooterList({
    super.key,
    required this.items,
    required this.onTap,
    required this.posterHeight,
  });

  final List<T> items;
  final PosterTap<T> onTap;
  final double posterHeight;

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final radius = BorderRadius.circular((12 * (shortest / 400)).clamp(10, 16).toDouble());

    return SizedBox(
      height: posterHeight + 16, // altura + padding inferior
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          
          // Adaptar para MovieModel y MockMovie
          String imageUrl;
          String title;
          
          if (item is MovieModel) {
            // Usar el helper API.poster() en lugar de construir URL manualmente
            imageUrl = item.posterPath != null 
                ? API.poster(item.posterPath!, size: 'w342')
                : '';
            title = item.title ?? 'Sin título';
          } else {
            // Para MockMovie (fallback)
            imageUrl = (item as dynamic).imageUrl as String;
            title = (item as dynamic).title as String;
          }

          return GestureDetector(
            onTap: () => onTap(item),
            child: ClipRRect(
              borderRadius: radius,
              child: AspectRatio(
                aspectRatio: 2 / 3, // póster clásico 1:1.5
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen
                    imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (c, w, p) {
                              if (p == null) return w;
                              return Container(
                                color: AppColors.primaryColor,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.redColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                          )
                        : _buildErrorPlaceholder(),
                    // Sombra sutil inferior para legibilidad
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0, 0.6),
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.secondColor.withOpacity(0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie,
            color: AppColors.whiteColor.withOpacity(0.5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(
              color: AppColors.whiteColor.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}