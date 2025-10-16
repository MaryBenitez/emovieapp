class API {
  // Bases
  static const String base = 'https://api.themoviedb.org/3';
  static const String imageBase = 'https://image.tmdb.org/t/p/';

  // Helpers de imágenes
  static String poster(String path, {String size = 'w342'}) => '$imageBase$size$path';
  static String backdrop(String path, {String size = 'w780'}) => '$imageBase$size$path';

  static String upcoming() => '/movie/upcoming';
  static String popular() => '/movie/popular';
  static String trending(String period) => '/trending/movie/$period';
  static String primaryTranslations() => '/configuration/primary_translations';
  static String detailsMovie(int idMovie) => '/movie/$idMovie';

  // Parámetros comunes
  static Map<String, dynamic> defaultQuery({
    int page = 1,
    String? language, // es-ES, en-US, etc.
    String? region,   // ES, MX, US, etc.
  }) {
    return {
      if (page > 1) 'page': '$page',
      if (language != null) 'language': language,
      if (region != null) 'region': region,
    };
  }

  // Parámetros de filtro para trending
  static Map<String, dynamic> trendingQuery({
    String? language, // 'es-ES', 'en-US'
    int? year,
  }) {
    return {
      if (language != null) 'language': language,
      if (year != null) 'primary_release_year': year.toString(),
    };
  }
}