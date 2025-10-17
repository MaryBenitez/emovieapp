import 'package:emovieapp/src/core/shared/animations/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final scale = (shortest / 400).clamp(0.85, 1.35);

    return AnimatedBackground(
      opacity: 0.08,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<MovieBloc, MovieState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () => handleRefresh(context),
                child: CustomScrollView(
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
                        context,
                        state, 
                        scale, 
                        (state) => state is MovieLoaded ? state.upcomingMovies : [],
                        'upcoming'
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
                        context,
                        state, 
                        scale, 
                        (state) => state is MovieLoaded ? state.popularMovies : [],
                        'popular'
                      ),
                    ),
                
                    // Recomendados
                    SliverToBoxAdapter( child: const CustomFilter()),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: BlocBuilder<MovieBloc, MovieState>(
                        builder: (context, state) {
                          if (state is MovieLoaded && state.isLoadingRecommendations) {
                            return SliverToBoxAdapter(
                              child: SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(color: AppColors.redColor),
                                ),
                              ),
                            );
                          }
                          
                          return RecommendedGrid<MovieModel>(
                            items: state is MovieLoaded ? state.recommendedMovies : [],
                            crossAxisCount: 2,
                            childAspectRatio: 0.70,
                            section: 'recommended',
                            onTap: (movie) {
                              _navigateToMovieDetail(context, movie, 'recommended');
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildMovieSection(
    BuildContext context,
    MovieState state, 
    double scale, 
    List<MovieModel> Function(MovieState) getMovies,
    String section,
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
        _navigateToMovieDetail(context, movie, section);
      },
      section: section,
    );
  }

  void _navigateToMovieDetail(BuildContext context, MovieModel movie, String section) {
    context.read<NavigationBloc>().add(
      NavigateToPage(routeName: '/movie_detail', useCustomTransition: true, arguments: {'movie': movie, 'heroTag': 'movie_${movie.id}_$section'})
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