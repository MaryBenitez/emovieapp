import 'package:flutter_test/flutter_test.dart';
import 'package:emovieapp/src/models/res/movie_model.dart';

void main() {
  group('MovieModel Tests', () {
    test('should create MovieModel from TMDB API response', () {
      // Arrange - Simular respuesta real de TMDB
      final tmdbResponse = {
        'id': 550,
        'title': 'Fight Club',
        'original_title': 'Fight Club',
        'overview': 'A ticking-time-bomb insomniac and a slippery soap salesman...',
        'release_date': '1999-10-15',
        'vote_average': 8.433,
        'vote_count': 26280,
        'popularity': 61.416,
        'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        'backdrop_path': '/87hTDiay2N2qWyX4Ds7ybXi9h8I.jpg',
        'original_language': 'en',
        'genre_ids': [18, 53],
        'adult': false,
        'video': false,
      };

      // Act - Convertir a modelo
      final movie = MovieModel.fromMap(tmdbResponse);

      // Assert - Verificar conversión correcta
      expect(movie.id, equals(550));
      expect(movie.title, equals('Fight Club'));
      expect(movie.voteAverage, equals(8.433));
      expect(movie.voteCount, equals(26280));
      expect(movie.genreIds, hasLength(2));
      expect(movie.genreIds, contains(18));
      expect(movie.adult, isFalse);
      expect(movie.posterPath, equals('/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
    });

    test('should handle numeric type conversion correctly', () {
      // Arrange - API a veces envía strings en lugar de números
      final malformedResponse = {
        'id': '299534', // String en lugar de int
        'title': 'Avengers: Endgame',
        'vote_average': '8.254', // String en lugar de double
        'vote_count': 24238.0, // Double en lugar de int
        'popularity': 114, // Int en lugar de double
      };

      // Act
      final movie = MovieModel.fromMap(malformedResponse);

      // Assert - Debe convertir correctamente los tipos
      expect(movie.id, equals(299534));
      expect(movie.voteAverage, equals(8.254));
      expect(movie.voteCount, equals(24238));
      expect(movie.popularity, equals(114.0));
    });

    test('should handle null and missing fields gracefully', () {
      // Arrange - Respuesta incompleta o con nulls
      final incompleteResponse = {
        'id': 123,
        'title': 'Test Movie',
        'vote_average': null,
        'poster_path': null,
        // release_date missing
        // genre_ids missing
      };

      // Act
      final movie = MovieModel.fromMap(incompleteResponse);

      // Assert - No debe crashear con campos null/faltantes
      expect(movie.id, equals(123));
      expect(movie.title, equals('Test Movie'));
      expect(movie.voteAverage, isNull);
      expect(movie.posterPath, isNull);
      expect(movie.releaseDate, isNull);
      expect(movie.genreIds, isNull);
    });

    test('should convert back to map correctly', () {
      // Arrange
      final originalMovie = MovieModel(
        id: 100,
        title: 'Test Movie',
        voteAverage: 7.5,
        releaseDate: '2024-01-01',
        genreIds: [28, 12],
        adult: false,
      );

      // Act
      final map = originalMovie.toMap();

      // Assert - Debe mantener snake_case y remover nulls
      expect(map['id'], equals(100));
      expect(map['title'], equals('Test Movie'));
      expect(map['vote_average'], equals(7.5));
      expect(map['release_date'], equals('2024-01-01'));
      expect(map['genre_ids'], equals([28, 12]));
      
      // Los campos null no deben aparecer en el map
      expect(map.containsKey('overview'), isFalse);
      expect(map.containsKey('poster_path'), isFalse);
    });

    test('should generate correct image URLs', () {
      // Arrange
      final movie = MovieModel(
        posterPath: '/test_poster.jpg',
        backdropPath: '/test_backdrop.jpg',
      );

      // Act & Assert - Verificar helpers de imagen
      expect(movie.posterUrl(), contains('/test_poster.jpg'));
      expect(movie.backdropUrl(), contains('/test_backdrop.jpg'));
      expect(movie.posterUrl(size: 'w500'), contains('w500'));
      expect(movie.backdropUrl(size: 'w1280'), contains('w1280'));
    });

    test('should handle copyWith correctly', () {
      // Arrange
      final originalMovie = MovieModel(
        id: 1,
        title: 'Original Title',
        voteAverage: 8.0,
      );

      // Act
      final updatedMovie = originalMovie.copyWith(
        title: 'Updated Title',
        voteCount: 1000,
      );

      // Assert - Debe mantener campos no cambiados y actualizar los nuevos
      expect(updatedMovie.id, equals(1)); // Se mantiene
      expect(updatedMovie.title, equals('Updated Title')); // Se actualiza
      expect(updatedMovie.voteAverage, equals(8.0)); // Se mantiene
      expect(updatedMovie.voteCount, equals(1000)); // Se agrega
    });
  });
}