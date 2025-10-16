import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';

class ConfigService {
  final ApiService _apiService;

  ConfigService({required ApiService apiService}) : _apiService = apiService;

  List<LanguageModel> listLanguages = [];

  Future<List<LanguageModel>> getPrimaryLanguages() async {
    try {
      final response = await _apiService.get(API.primaryTranslations());
      
      // Respuesta es directamente una Lista de strings, no un Map
      final List<dynamic> languageCodes = response as List<dynamic>;
      
      // Convertir códigos a objetos LanguageModel y filtrar los más importantes
      final priorityLanguages = [
        'es-ES', 'en-US', 'fr-FR', 'de-DE', 'it-IT', 'pt-BR', 
        'ja-JP', 'ko-KR', 'zh-CN', 'ru-RU', 'ar-SA', 'hi-IN'
      ];

      // Filtrar solo los idiomas prioritarios que existen en la respuesta
      listLanguages = priorityLanguages
          .where((code) => languageCodes.contains(code))
          .map((code) => LanguageModel.fromCode(code))
          .toList();

      return listLanguages;
      
    } catch (e) {
      debugPrint('getPrimaryLanguages Error :: $e');
      showToastMessage(
        message: 'Error fetching languages: $e', 
        backgroundColor: AppColors.redColor, 
        textColor: AppColors.whiteColor
      );
      
      // Fallback con idiomas básicos, manteniendo la misma estructura
      listLanguages = [
        LanguageModel.fromCode('es-ES'),
        LanguageModel.fromCode('en-US'),
        LanguageModel.fromCode('fr-FR'),
        LanguageModel.fromCode('de-DE'),
        LanguageModel.fromCode('it-IT'),
        LanguageModel.fromCode('pt-BR'),
      ];
      
      return listLanguages;
    }
  }

}