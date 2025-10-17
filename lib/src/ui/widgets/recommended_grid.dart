import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

typedef GridTap<T> = void Function(T item);

class RecommendedGrid<T> extends StatelessWidget {
  const RecommendedGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
    this.section = 'recommended'
  });

  final List<T> items;
  final GridTap<T> onTap;
  final int crossAxisCount;
  final double childAspectRatio;
  final String section;

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final radius = BorderRadius.circular((14 * (shortest / 400)).clamp(12, 18).toDouble());

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          
          // Adaptar para MovieModel
          String imageUrl;
          String title;
          dynamic itemId;
          
          if (item is MovieModel) {
            imageUrl = item.posterPath != null 
                ? API.poster(item.posterPath!, size: 'w342')
                : '';
            title = item.title ?? 'Sin título';
            itemId = item.id; // OBTENER ID
          } else {
            // Fallback para MockMovie
            imageUrl = (item as dynamic).imageUrl as String;
            title = (item as dynamic).title as String;
            itemId = (item as dynamic).id; // OBTENER ID
          }

          return GestureDetector(
            onTap: () => onTap(item),
            child: Hero(
              tag: 'movie_${itemId}_$section',
              child: ClipRRect(
                borderRadius: radius,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
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
                                    color: AppColors.secondColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                          )
                        : _buildErrorPlaceholder(),
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
        childCount: items.length.clamp(0, 6),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
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
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            'Sin imagen',
            style: TextStyle(
              color: AppColors.whiteColor.withOpacity(0.5),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}