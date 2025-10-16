import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

typedef PosterTap<T> = void Function(T item);

class HPooterList<T> extends StatelessWidget {
  final List<T> items;
  final double posterHeight;
  final String section; // AGREGAR ESTO
  final Function(T)? onTap;

  const HPooterList({
    super.key,
    required this.items,
    required this.posterHeight,
    required this.section, // AGREGAR ESTO
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(
        height: posterHeight,
        child: Center(
          child: Text(
            'No hay películas disponibles',
            style: TextStyle(color: AppColors.whiteColor),
          ),
        ),
      );
    }

    return SizedBox(
      height: posterHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildPosterItem(item, posterHeight, section); // PASAR SECTION
        },
      ),
    );
  }

  Widget _buildPosterItem(T item, double posterHeight, String section) {
    return GestureDetector(
      onTap: () => onTap?.call(item),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Hero(
          tag: 'movie_${(item as dynamic).id}_$section',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              ImageHelper.poster((item as dynamic).posterPath ?? ''),
              width: posterHeight * 0.67,
              height: posterHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: posterHeight * 0.67,
                  height: posterHeight,
                  color: Colors.grey[800],
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                    size: 32,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}