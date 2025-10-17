import 'dart:io';
import 'package:emovieapp/src/imports/imports.dart';

class ConfigService {
	final ApiService _apiService;
	final CacheService _cache;
  final ConnectivityService _connectivityService = ConnectivityService();

	ConfigService({
		required ApiService apiService,
		required CacheService cache,
	})  : _apiService = apiService,
		  _cache = cache;

	// Cache en memoria
	List<LanguageModel> listLanguages = [];

	// TTL largo: las traducciones cambian cada 7 días para evitar llamadas innecesarias
	static const int _ttlPrimaryTranslationsMinutes = 60 * 24 * 7;

	// Clave de caché única 
	static const String _kPrimaryTranslations = 'GET:/configuration/primary_translations';

	Future<List<LanguageModel>> getPrimaryLanguages() async {

    final isConnected = await _connectivityService.checkConnectionNow();
    if (!isConnected) {
      final cached = await _cache.getJson(_kPrimaryTranslations, ttlMinutes: _ttlPrimaryTranslationsMinutes);
      if (cached != null && cached['list'] is List) {
        final langs = _mapAndFilterPriority(List<dynamic>.from(cached['list']));
        listLanguages = langs;
        return langs;
      }
      final fallback = _fallbackLanguages();
      listLanguages = fallback;
      return fallback;
    }

		try {
			// 1) RED
			final response = await _apiService.get(API.primaryTranslations());

			// La respuesta es una lista de strings, no un Map
			final List<dynamic> languageCodes = response as List<dynamic>;

			// Guardar en caché envolviendo la lista en un Map
			await _cache.setJson(_kPrimaryTranslations, {'list': languageCodes});

			final langs = _mapAndFilterPriority(languageCodes);
			listLanguages = langs;
			return langs;
		} on DioException catch (e) {
			// 2) OFFLINE/TIMEOUT - intentar caché en silencio
			final isNetworkishError = e.type == DioExceptionType.connectionTimeout ||
				e.type == DioExceptionType.sendTimeout ||
				e.type == DioExceptionType.receiveTimeout ||
				e.error is SocketException ||
				e.type == DioExceptionType.unknown;

			if (isNetworkishError) {
				final cached = await _cache.getJson(_kPrimaryTranslations, ttlMinutes: _ttlPrimaryTranslationsMinutes);
				if (cached != null && cached['list'] is List) {
					final langs = _mapAndFilterPriority(List<dynamic>.from(cached['list']));
					listLanguages = langs;
					return langs; // silencioso si hay caché
				}

				// Sin red y sin caché → fallback local sin toast molesto
				final fallback = _fallbackLanguages();
				listLanguages = fallback;
				return fallback;
			}

			// Probamos caché por si existe
			final cached = await _cache.getJson(_kPrimaryTranslations, ttlMinutes: _ttlPrimaryTranslationsMinutes);
			if (cached != null && cached['list'] is List) {
				final langs = _mapAndFilterPriority(List<dynamic>.from(cached['list']));
				listLanguages = langs;
				return langs;
			}

			// Sin caché
			showToastMessage(
				message: 'Error cargando idiomas: ${e.response?.statusMessage ?? e.message}',
				backgroundColor: AppColors.redColor,
				textColor: AppColors.whiteColor,
			);
			final fallback = _fallbackLanguages();
			listLanguages = fallback;
			return fallback;
		} catch (e) {
			// Cualquier otro error - intentar caché
			final cached = await _cache.getJson(_kPrimaryTranslations, ttlMinutes: _ttlPrimaryTranslationsMinutes);
			if (cached != null && cached['list'] is List) {
				final langs = _mapAndFilterPriority(List<dynamic>.from(cached['list']));
				listLanguages = langs;
				return langs;
			}

			// Sin caché - fallback - toast único
			showToastMessage(
				message: 'Error fetching languages: $e',
				backgroundColor: AppColors.redColor,
				textColor: AppColors.whiteColor,
			);
			final fallback = _fallbackLanguages();
			listLanguages = fallback;
			return fallback;
		}
	}

	// Mapea y filtra por prioridad conservando solo códigos presentes en la respuesta.
	List<LanguageModel> _mapAndFilterPriority(List<dynamic> languageCodes) {
		final codes = languageCodes.map((e) => e.toString()).toSet();

		// Prioridad (ajústala a tu UI/región)
		const priority = <String>[
			'es-ES','es-MX','en-US','pt-BR','fr-FR','de-DE','it-IT',
			'ja-JP','ko-KR','zh-CN','ru-RU','ar-SA','hi-IN',
		];

		// Filtra solo los que vengan en la respuesta, conserva orden de prioridad
		final filtered = priority.where(codes.contains).toList();


		// Mapea a LanguageModel
		return filtered.map(LanguageModel.fromCode).toList();
	}

	// Fallback local mínimo y útil si no hay red ni caché.
	List<LanguageModel> _fallbackLanguages() => <LanguageModel>[
		LanguageModel.fromCode('es-ES'),
		LanguageModel.fromCode('en-US'),
		LanguageModel.fromCode('pt-BR'),
		LanguageModel.fromCode('fr-FR'),
		LanguageModel.fromCode('de-DE'),
		LanguageModel.fromCode('it-IT'),
	];
}
