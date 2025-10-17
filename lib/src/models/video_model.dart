class VideoModel {
  final String? id;
  final String? iso6391;
  final String? iso31661;
  final String? key;
  final String? name;
  final String? site;
  final int? size;
  final String? type;
  final bool? official;
  final String? publishedAt;

  const VideoModel({
    this.id,
    this.iso6391,
    this.iso31661,
    this.key,
    this.name,
    this.site,
    this.size,
    this.type,
    this.official,
    this.publishedAt,
  });

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String?,
      iso6391: json['iso_639_1'] as String?,
      iso31661: json['iso_3166_1'] as String?,
      key: json['key'] as String?,
      name: json['name'] as String?,
      site: json['site'] as String?,
      size: _asInt(json['size']),
      type: json['type'] as String?,
      official: json['official'] as bool?,
      publishedAt: json['published_at'] as String?,
    );
  }

  // Getters útiles
  String get youtubeUrl => key != null ? 'https://www.youtube.com/watch?v=$key' : '';
  String get youtubeThumbnail => key != null ? 'https://img.youtube.com/vi/$key/maxresdefault.jpg' : '';
  
  bool get isYouTubeTrailer => site == 'YouTube' && type == 'Trailer';
  bool get isOfficialTrailer => isYouTubeTrailer && (official == true);
  
  String get displayName => name ?? 'Video';
}

class VideosResponse {
  final int? id;
  final List<VideoModel> results;

  const VideosResponse({
    this.id,
    required this.results,
  });

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory VideosResponse.fromJson(Map<String, dynamic> json) {
    return VideosResponse(
      id: _asInt(json['id']),
      results: (json['results'] as List?)
          ?.map((video) => VideoModel.fromJson(video))
          .toList() ?? [],
    );
  }
  
  // LÓGICA DEL MEJOR TRAILER
  VideoModel? get bestTrailer {
    if (results.isEmpty) return null;
    
    // Prioridad 1: Trailer oficial de YouTube
    final officialTrailers = results.where((v) => 
        v.site == 'YouTube' && 
        v.type == 'Trailer' && 
        v.official == true &&
        v.key != null
    ).toList();
    
    if (officialTrailers.isNotEmpty) {
      return officialTrailers.first;
    }
    
    // Prioridad 2: Cualquier trailer de YouTube
    final youtubeTrailers = results.where((v) => 
        v.site == 'YouTube' && 
        v.type == 'Trailer' &&
        v.key != null
    ).toList();
    
    if (youtubeTrailers.isNotEmpty) {
      return youtubeTrailers.first;
    }
    
    // Prioridad 3: Cualquier teaser oficial de YouTube
    final officialTeasers = results.where((v) => 
        v.site == 'YouTube' && 
        v.type == 'Teaser' && 
        v.official == true &&
        v.key != null
    ).toList();
    
    if (officialTeasers.isNotEmpty) {
      return officialTeasers.first;
    }
    
    // Prioridad 4: Cualquier video de YouTube con key válida
    final youtubeVideos = results.where((v) => 
        v.site == 'YouTube' && 
        v.key != null && 
        v.key!.isNotEmpty
    ).toList();
    
    if (youtubeVideos.isNotEmpty) {
      return youtubeVideos.first;
    }
    
    return null;
  }
  
  List<VideoModel> get trailers => results.where((v) => v.type == 'Trailer').toList();
  List<VideoModel> get youtubeVideos => results.where((v) => v.site == 'YouTube').toList();
}