import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';

class MovieParticle {
  final IconData icon;
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double pulsePhase;

  MovieParticle({
    required this.icon,
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.pulsePhase,
  });
}

class ImageHelper {
  static const String _base = 'https://image.tmdb.org/t/p/';
  static String poster(String? path, {String size = 'w342'}) => (path == null || path.isEmpty) ? '' : '$_base$size$path';
  static String backdrop(String? path, {String size = 'w780'}) => (path == null || path.isEmpty) ? '' : '$_base$size$path';
}

class FilterData {
  final List<LanguageModel> languages;
  final List<int> years;
  final String? selectedLanguage;
  final int? selectedYear;
  final String selectedPeriod;

  const FilterData({
    this.languages = const [],
    this.years = const [],
    this.selectedLanguage,
    this.selectedYear,
    this.selectedPeriod = 'day',
  });

  FilterData copyWith({
    List<LanguageModel>? languages,
    List<int>? years,
    String? selectedLanguage,
    int? selectedYear,
    String? selectedPeriod,
  }) {
    return FilterData(
      languages: languages ?? this.languages,
      years: years ?? this.years,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  FilterData copyWithNullable({
    List<LanguageModel>? languages,
    List<int>? years,
    String? selectedLanguage,
    int? selectedYear,
    String? selectedPeriod,
    bool clearLanguage = false,
    bool clearYear = false,
  }) {
    return FilterData(
      languages: languages ?? this.languages,
      years: years ?? this.years,
      selectedLanguage: clearLanguage ? null : (selectedLanguage ?? this.selectedLanguage),
      selectedYear: clearYear ? null : (selectedYear ?? this.selectedYear),
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  static List<int> generateYears() {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 1899, (index) => currentYear - index);
  }

  LanguageModel? get selectedLanguageModel {
    if (selectedLanguage == null) return null;
    return languages.where((lang) => lang.code == selectedLanguage).firstOrNull;
  }

  String get periodDisplayName {
    switch (selectedPeriod) {
      case 'day':
        return '📅 Hoy';
      case 'week':
        return '📊 Esta semana';
      default:
        return '📊 Esta semana';
    }
  }

  String get languageDisplayText {
    if (selectedLanguage == null) return '';
    final lang = selectedLanguageModel;
    return lang?.displayName ?? '';
  }

  String get yearDisplayText {
    if (selectedYear == null) return '';
    return '📅 Año $selectedYear';
  }

  // Verificar si hay filtros activos
  bool get hasActiveFilters {
    return selectedLanguage != null || 
           selectedYear != null || 
           selectedPeriod != 'day';
  }

  // Verificar filtros individuales
  bool get hasPeriodFilter => selectedPeriod != 'day';
  bool get hasLanguageFilter => selectedLanguage != null;
  bool get hasYearFilter => selectedYear != null;
}