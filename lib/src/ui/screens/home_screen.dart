import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final scale = (shortest / 400).clamp(0.85, 1.35);

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _Logo(scale: scale),
                  ),
                ),
            
                // Próximos estrenos
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: SectionTitle(text: 'Próximos estrenos'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildMovieSection(
                    state, 
                    scale, 
                    (state) => state is MovieLoaded ? state.upcomingMovies : []
                  ),
                ),
            
                // Tendencia
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: SectionTitle(text: 'Tendencia'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildMovieSection(
                    state, 
                    scale, 
                    (state) => state is MovieLoaded ? state.popularMovies : []
                  ),
                ),
            
                // Recomendados
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: SectionTitle(text: 'Recomendados para ti'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _FiltersBar(
                      // TODO: conectar con estado/BLoC cuando haya API
                      chips: const ['En español', 'Lanzadas en 1993'],
                      onTap: (label) {},
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: RecommendedGrid(
                    items: _mockRecommended, // TODO
                    crossAxisCount: 2,
                    childAspectRatio: 0.70, // cards altas tipo póster
                    onTap: (m) {/* TODO */},
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildMovieSection(
    MovieState state, 
    double scale, 
    List<MovieModel> Function(MovieState) getMovies
  ) {
    if (state is MovieLoading) {
      return SizedBox(
        height: 200 * scale,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondColor),
        ),
      );
    }
    
    if (state is MovieError) {
      return SizedBox(
        height: 200 * scale,
        child: Center(
          child: Text(
            'Error: ${state.message}',
            style: TextStyle(color: AppColors.whiteColor),
          ),
        ),
      );
    }
    
    final movies = getMovies(state);
    return HPooterList<MovieModel>(
      items: movies,
      posterHeight: 200 * scale,
      onTap: (movie) {
        print('Tapped on: ${movie.title}');
      },
    );
  }
    
}

class _Logo extends StatelessWidget {
  const _Logo({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    final fs = (20 * scale).clamp(16, 24).toDouble();
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.whiteColor, width: 1.2),
          borderRadius: BorderRadius.circular(6),
          color: AppColors.whiteColor.withOpacity(0.04),
        ),
        child: Text(
          'eMovie',
          style: TextStyle(
            fontSize: fs,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({required this.chips, required this.onTap});
  final List<String> chips;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips
          .map((c) => GestureDetector(
                onTap: () => onTap(c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.whiteColor.withOpacity(0.9), width: 1),
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Text(
                    c,
                    style: const TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

/// -------------------- MOCK DATA (quitar cuando conectes el servicio) --------------------
class MockMovie {
  final String id;
  final String title;
  final String imageUrl;
  const MockMovie(this.id, this.title, this.imageUrl);
}

const _mockTrending = <MockMovie>[
  MockMovie('5', 'The Third Man', 'https://image.tmdb.org/t/p/w342/9HmpyZkS7jHimoMuNoMNFc13JUo.jpg'),
  MockMovie('6', 'Braveheart', 'https://image.tmdb.org/t/p/w342/1N4Y8fNwCu6Jz1Ww2x2n6RSPdZ3.jpg'),
  MockMovie('7', 'Amélie', 'https://image.tmdb.org/t/p/w342/wnUAcUrMRGPPZUDroLeZhSjLkuu.jpg'),
  MockMovie('8', 'Her', 'https://image.tmdb.org/t/p/w342/eCOtqTBorMiI3n6SCFZ8WttMBIg.jpg'),
];

const _mockRecommended = <MockMovie>[
  MockMovie('9', 'Her', 'https://image.tmdb.org/t/p/w342/eCOtqTBorMiI3n6SCFZ8WttMBIg.jpg'),
  MockMovie('10', 'Prometheus', 'https://image.tmdb.org/t/p/w342/ng8ALjSDhUmwLl7vbPPfnNn2CSz.jpg'),
  MockMovie('11', 'Blade Runner 2049', 'https://image.tmdb.org/t/p/w342/aMpyrCizvSgQrLHJNds0bMu3XA3.jpg'),
  MockMovie('12', 'Mad Max: Fury Road', 'https://image.tmdb.org/t/p/w342/kqjL17yufvn9OVLyXYpvtyrFfak.jpg'),
];
