import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

  // VARIABLES PARA VIDEO
  VideoPlayerController? _videoController;
  bool _isPlayingVideo = false;
  bool _isVideoLoading = false;
  String? _currentVideoUrl;

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
    context.read<MovieBloc>().add(LoadMovieVideos(movieId: widget.movie.id ?? 0));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  // MANEJAR VIDEO
  Future<void> _playVideoInline(String youtubeKey) async {
    try {
      setState(() {
        _isVideoLoading = true;
      });

      // URL del video de YouTube (usando formato directo)
      // Nota: Para producción, considera usar youtube_player_flutter
      final videoUrl = 'https://www.youtube.com/embed/$youtubeKey?autoplay=1';
      
      setState(() {
        _isPlayingVideo = true;
        _isVideoLoading = false;
        _currentVideoUrl = youtubeKey;
      });

    } catch (e) {
      setState(() {
        _isVideoLoading = false;
      });
      
      // Fallback: abrir en YouTube
      openTrailer(context, 'https://www.youtube.com/watch?v=$youtubeKey');
    }
  }

  void _stopVideo() {
    _videoController?.dispose();
    _videoController = null;
    setState(() {
      _isPlayingVideo = false;
      _currentVideoUrl = null;
    });
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
              // IMAGEN BACKDROP SIN ESPACIO ADICIONAL
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Stack(
                    children: [

                      // CONTENEDOR PRINCIPAL - IMAGEN O VIDEO
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 220, // Altura fija para consistencia
                          child: _isPlayingVideo 
                              ? _buildVideoPlayerReal() 
                              : _buildBackdropImage(),
                        ),
                      ),
                      
                      // BOTÓN VER TRAILER
                      if (!_isPlayingVideo) ...[
                        Positioned(
                          bottom: 5,
                          left: 20,
                          right: 20,
                          child: _buildTrailerButton(),
                        ),
                      ],
                      
                      // CONTROLES DE VIDEO (cuando está reproduciendo)
                      if (_isPlayingVideo) ...[
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _stopVideo,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColors.whiteColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      // LOADING INDICATOR
                      if (_isVideoLoading) ...[
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.7),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: AppColors.secondColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Cargando video...',
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // CONTENIDO
              _buildContent(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackdropImage() {
    return widget.movie.backdropPath != null && widget.movie.backdropPath!.isNotEmpty
        ? Image.network(
            ImageHelper.backdrop(widget.movie.backdropPath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.primaryColor,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondColor,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.primaryColor,
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.whiteColor.withOpacity(0.3),
                  size: 32,
                ),
              );
            },
          )
        : Container(
            color: AppColors.primaryColor,
            child: Icon(
              Icons.image_not_supported,
              color: AppColors.whiteColor.withOpacity(0.3),
              size: 32,
            ),
          );
  }

  Widget _buildVideoPlayerReal() {
      if (_currentVideoUrl == null) return Container();
      
      return YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: _currentVideoUrl!,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        ),
        showVideoProgressIndicator: true,
        onReady: () {},
        onEnded: (data) {
          _stopVideo(); // Volver a la imagen cuando termine
        },
      );
    }

  Widget _buildTrailerButton() {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        VideosResponse? videosResponse;
        
        if (state is MovieLoaded) {
          videosResponse = state.currentVideos;
        } else if (state is MovieVideosLoaded) {
          videosResponse = state.videosResponse;
        }
        
        if (videosResponse == null) {
          return _buildNoTrailerButton();
        }
        
        final trailer = videosResponse.bestTrailer;
        final hasTrailer = trailer?.key != null && trailer!.key!.isNotEmpty;
        
        return GestureDetector(
          onTap: () {
            if (hasTrailer && trailer != null) {
              _playVideoInline(trailer.key!);
            } else {
              showNoTrailerDialog(context);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: hasTrailer 
                  ? AppColors.secondColor.withOpacity(0.9)
                  : AppColors.primaryColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.whiteColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasTrailer ? Icons.play_arrow : Icons.info_outline,
                    color: AppColors.whiteColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasTrailer 
                        ? 'Ver ${trailer.type?.toLowerCase() ?? 'video'}'
                        : 'Sin trailer (${videosResponse.results.length} videos)',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoTrailerButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.whiteColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.whiteColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Cargando...',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final opacity = (_scrollOffset / 200).clamp(0.0, 1.0); // suavidad
    
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
            Navigator.of(context).pop(); 
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

            // OVERLAY NEGRO OPACO SOBRE TODA LA IMAGEN
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
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
              bottom: 60,
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
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BUSCAR DETALLES EN TODOS LOS ESTADOS
                  if (state is MovieLoaded && state.currentMovieDetail != null) ...[
                    _buildPlotSection(state.currentMovieDetail!.overview ?? ''),
                    const SizedBox(height: 24),
                    _buildMovieStats(state.currentMovieDetail!),
                  ] else if (state is MovieDetailLoaded) ...[
                    _buildPlotSection(state.movieDetail.overview ?? ''),
                    const SizedBox(height: 24),
                    _buildMovieStats(state.movieDetail),
                  ] else if (state is MovieDetailWithVideosLoaded) ...[
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
                    _buildPlotSection(widget.movie.overview ?? ''),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieBasicInfo() {
    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        List<String> genres = [];
      
        // BUSCAR GÉNEROS EN TODOS LOS ESTADOS POSIBLES
        if (state is MovieLoaded && state.currentMovieDetail != null) {
          genres = state.currentMovieDetail!.genreNames;
        } else if (state is MovieDetailLoaded) {
          genres = state.movieDetail.genreNames;
        } else if (state is MovieDetailWithVideosLoaded) {
          genres = state.movieDetail.genreNames;
        } else {}
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.movie.title ?? '',
              textAlign: TextAlign.center,
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
            const SizedBox(height: 15),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.movie.releaseDate?.substring(0, 4) ?? 'N/A',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.movie.originalLanguage?.toUpperCase() ?? 'EN',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.yellowColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.movie.voteAverage?.toStringAsFixed(1) ?? '0.0',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            const SizedBox(height: 15),
            // GÉNEROS
            _buildGenres(genres),
            const SizedBox(height: 15),
            Tooltip(
              message: "Desliza hacia arriba",
              child: Icon(Icons.swipe_up, color: AppColors.whiteColor)
            ),
            const SizedBox(height: 5),
            Text('Desliza hacia arriba',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildGenres(List<String> genres) {
    final displayGenres = genres.isNotEmpty ? genres : [];
    
    return Wrap(
      spacing: 8,
      children: displayGenres.toList().asMap().entries.map((entry) {
        int index = entry.key;
        String genre = entry.value;
        bool isLast = index == displayGenres.length - 1;
        
        return Text(
          isLast ? genre : '$genre •',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlotSection(String overview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
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