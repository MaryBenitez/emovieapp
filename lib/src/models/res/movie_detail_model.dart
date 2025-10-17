import 'package:emovieapp/src/imports/imports.dart';

class MovieDetailModel {
  final bool? adult;
  final String? backdropPath;
  final int? budget;
  final List<GenreModel>? genres;
  final String? homepage;
  final int? id;
  final String? imdbId;
  final String? originalLanguage;
  final String? originalTitle;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final List<ProductionCompanyModel>? productionCompanies;
  final List<ProductionCountryModel>? productionCountries;
  final String? releaseDate;
  final int? revenue;
  final int? runtime;
  final List<SpokenLanguageModel>? spokenLanguages;
  final String? status;
  final String? tagline;
  final String? title;
  final bool? video;
  final double? voteAverage;
  final int? voteCount;
  final List<VideoModel>? videos; 

  const MovieDetailModel({
    this.adult,
    this.backdropPath,
    this.budget,
    this.genres,
    this.homepage,
    this.id,
    this.imdbId,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    this.productionCompanies,
    this.productionCountries,
    this.releaseDate,
    this.revenue,
    this.runtime,
    this.spokenLanguages,
    this.status,
    this.tagline,
    this.title,
    this.video,
    this.voteAverage,
    this.voteCount,
    this.videos, 
  });

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailModel(
      adult: json['adult'] as bool?,
      backdropPath: json['backdrop_path'] as String?,
      budget: _asInt(json['budget']),
      genres: (json['genres'] as List?)?.map((g) => GenreModel.fromJson(g)).toList(),
      homepage: json['homepage'] as String?,
      id: _asInt(json['id']),
      imdbId: json['imdb_id'] as String?,
      originalLanguage: json['original_language'] as String?,
      originalTitle: json['original_title'] as String?,
      overview: json['overview'] as String?,
      popularity: _asDouble(json['popularity']),
      posterPath: json['poster_path'] as String?,
      productionCompanies: (json['production_companies'] as List?)?.map((pc) => ProductionCompanyModel.fromJson(pc)).toList(),
      productionCountries: (json['production_countries'] as List?)?.map((pc) => ProductionCountryModel.fromJson(pc)).toList(),
      releaseDate: json['release_date'] as String?,
      revenue: _asInt(json['revenue']),
      runtime: _asInt(json['runtime']),
      spokenLanguages: (json['spoken_languages'] as List?)?.map((sl) => SpokenLanguageModel.fromJson(sl)).toList(),
      status: json['status'] as String?,
      tagline: json['tagline'] as String?,
      title: json['title'] as String?,
      video: json['video'] as bool?,
      voteAverage: _asDouble(json['vote_average']),
      voteCount: _asInt(json['vote_count']),
      videos: (json['videos']?['results'] as List?)?.map((v) => VideoModel.fromJson(v)).toList(),
    );
  }

  // Getters útiles con null safety
  String get year => (releaseDate?.isNotEmpty == true) ? releaseDate!.substring(0, 4) : '';
  
  String get formattedRuntime {
    if (runtime == null || runtime! <= 0) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get ratingText => voteAverage?.toStringAsFixed(1) ?? '0.0';

  List<String> get genreNames => genres?.map((g) => g.name ?? '').where((name) => name.isNotEmpty).toList() ?? [];

  String get formattedBudget {
    if (budget == null || budget! <= 0) return '';
    if (budget! >= 1000000) {
      return '\$${(budget! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${budget!.toString()}';
  }

  String get formattedRevenue {
    if (revenue == null || revenue! <= 0) return '';
    if (revenue! >= 1000000) {
      return '\$${(revenue! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${revenue!.toString()}';
  }

  // Helpers de imagen
  String posterUrl({String size = 'w342'}) => ImageHelper.poster(posterPath, size: size);
  String backdropUrl({String size = 'w780'}) => ImageHelper.backdrop(backdropPath, size: size);
}