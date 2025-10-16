import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;
  final String heroTag;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.heroTag,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  double _scrollOffset = 0.0;
  static const double _expandedHeight = 400.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 0.8).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });

      if (_scrollOffset > 100 && !_fadeController.isAnimating) {
        _fadeController.forward();
      } else if (_scrollOffset <= 100 && !_fadeController.isAnimating) {
        _fadeController.reverse();
      }
    });

    // Cargar detalles de la película
    context.read<MovieBloc>().add(LoadMovieDetail(movieId: widget.movie.id ?? 0));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              // AGREGAR UN ESPACIO INICIAL PARA VER LA IMAGEN COMPLETA
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6, // 60% de la pantalla
                  child: Container(), // Espacio vacío para que se vea la imagen
                ),
              ),
              _buildContent(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    final opacity = (_scrollOffset / 200).clamp(0.0, 1.0); // Cambiar a 200 para más suavidad
    
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height, // ALTURA COMPLETA DE LA PANTALLA
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryColor.withOpacity(opacity),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
          onPressed: () {
            context.read<NavigationBloc>().add(
              const NavigateToPage(routeName: '/home'),
            );
          },
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // POSTER CON HERO ANIMATION (PRINCIPAL) - IMAGEN COMPLETA
            Hero(
              tag: widget.heroTag,
              child: widget.movie.posterPath != null && widget.movie.posterPath!.isNotEmpty
                  ? Image.network(
                      ImageHelper.poster(widget.movie.posterPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primaryColor,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.whiteColor.withOpacity(0.3),
                            size: 64,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.primaryColor,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.whiteColor.withOpacity(0.3),
                        size: 64,
                      ),
                    ),
            ),
            
            // GRADIENTE SUAVE SOLO EN LA PARTE INFERIOR
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            
            // INFO DE LA PELÍCULA EN LA PARTE INFERIOR
            Positioned(
              bottom: 60, // Más arriba para que no se corte
              left: 20,
              right: 20,
              child: _buildMovieBasicInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(MovieState state) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), // Bordes más redondeados
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24), // Más padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INDICADOR DE ARRASTRE
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              if (state is MovieDetailLoaded) ...[
                _buildGenres(state.movieDetail.genreNames),
                const SizedBox(height: 20),
                _buildTrailerButton(),
                const SizedBox(height: 24),
                _buildPlotSection(state.movieDetail.overview ?? ''),
                const SizedBox(height: 24),
                _buildMovieStats(state.movieDetail),
              ] else if (state is MovieLoading) ...[
                const SizedBox(height: 200),
                Center(
                  child: CircularProgressIndicator(color: AppColors.secondColor),
                ),
              ] else if (state is MovieDetailError) ...[
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.error, color: AppColors.redColor, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: TextStyle(color: AppColors.whiteColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildGenres([]),
                const SizedBox(height: 20),
                _buildTrailerButton(),
                const SizedBox(height: 24),
                _buildPlotSection(widget.movie.overview ?? ''),
              ],
              const SizedBox(height: 60), // Más espacio al final
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.movie.title ?? '',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.movie.releaseDate.toString(),
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.movie.originalLanguage?.toUpperCase() ?? 'EN',
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.whiteColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.movie.voteAverage?.toStringAsFixed(1) ?? '0.0',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenres(List<String> genres) {
    final displayGenres = genres.isNotEmpty ? genres : ['Heartfelt', 'Romance', 'Sci-fi', 'Drama'];
    
    return Wrap(
      spacing: 8,
      children: displayGenres.take(4).map((genre) => Text(
        '$genre • ',
        style: TextStyle(
          color: AppColors.whiteColor.withOpacity(0.8),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      )).toList(),
    );
  }

  Widget _buildTrailerButton() {
    return GestureDetector(
      onTap: () {
        // Implementar reproducción de trailer
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.whiteColor.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Ver trailer',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlotSection(String overview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOVIE PLOT',
          style: TextStyle(
            color: AppColors.whiteColor.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          overview.isNotEmpty ? overview : widget.movie.overview ?? '',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildMovieStats(MovieDetailModel movie) {
    return Column(
      children: [
        if (movie.formattedRuntime.isNotEmpty)
          _buildStatRow('Duración', movie.formattedRuntime),
        if (movie.status?.isNotEmpty == true)
          _buildStatRow('Estado', movie.status!),
        if (movie.originalLanguage?.isNotEmpty == true)
          _buildStatRow('Idioma original', movie.originalLanguage!.toUpperCase()),
        if (movie.formattedBudget.isNotEmpty)
          _buildStatRow('Presupuesto', movie.formattedBudget),
        if (movie.formattedRevenue.isNotEmpty)
          _buildStatRow('Recaudación', movie.formattedRevenue),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.whiteColor.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}