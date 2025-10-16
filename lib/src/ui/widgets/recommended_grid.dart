import 'package:flutter/material.dart';

typedef GridTap<T> = void Function(T item);

class RecommendedGrid<T> extends StatelessWidget {
  const RecommendedGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.7,
  });

  final List<T> items;
  final GridTap<T> onTap;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final radius = BorderRadius.circular((14 * (shortest / 400)).clamp(12, 18).toDouble());

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          final imageUrl = (item as dynamic).imageUrl as String;
          final title = (item as dynamic).title as String;

          return GestureDetector(
            onTap: () => onTap(item),
            child: ClipRRect(
              borderRadius: radius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (c, w, p) => p == null ? w : Container(color: Colors.white10),
                    errorBuilder: (_, __, ___) => Container(color: Colors.white10),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0, 0.6),
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 8,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: items.length.clamp(0, 6), // máximo 6 como pide la prueba
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: childAspectRatio,
      ),
    );
  }
}
