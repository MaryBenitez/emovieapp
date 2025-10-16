
import 'dart:convert';

import 'package:emovieapp/src/imports/imports.dart';

class PagedMovieModels {
  int? page;
  int? totalPages;
  int? totalResults;
  List<MovieModel>? results;

  PagedMovieModels({
    this.page,
    this.totalPages,
    this.totalResults,
    this.results,
  });

  PagedMovieModels copyWith({
    int? page,
    int? totalPages,
    int? totalResults,
    List<MovieModel>? results,
  }) {
    return PagedMovieModels(
      page          : page          ?? this.page,
      totalPages    : totalPages    ?? this.totalPages,
      totalResults  : totalResults  ?? this.totalResults,
      results       : results       ?? this.results,
    );
  }

  factory PagedMovieModels.fromJson(String str) => PagedMovieModels.fromMap(json.decode(str));
  String toJson() => json.encode(toMap());

  factory PagedMovieModels.fromMap(Map<String, dynamic> json) => PagedMovieModels(
        page          : json['page'],
        totalPages    : json['total_pages'],
        totalResults  : json['total_results'],
        results       : (json['results'] as List?)?.map((e) => MovieModel.fromMap(e as Map<String, dynamic>)).toList(),
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'page'          : page,
      'total_pages'   : totalPages,
      'total_results' : totalResults,
      'results'       : results?.map((e) => e.toMap()).toList(),
    };
    map.removeWhere((k, v) => v == null);
    return map;
  }
}