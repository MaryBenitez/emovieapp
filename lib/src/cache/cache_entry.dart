import 'dart:convert';

import 'package:emovieapp/src/imports/imports.dart';

class CacheEntry {
	final String data; 
	final int savedAtMillis; 

	CacheEntry({required this.data, required this.savedAtMillis});

	Map<String, dynamic> toMap() => {
		'data': data,
		'savedAt': savedAtMillis,
	};

	static CacheEntry? fromMap(Map<String, dynamic>? map) {
		if (map == null) return null;
		final data = map['data'] as String?;
		final savedAt = map['savedAt'] as int?;
		if (data == null || savedAt == null) return null;
		return CacheEntry(data: data, savedAtMillis: savedAt);
	}
}

class CacheService {
	static const _prefix = 'cache:';

	SharedPreferences? _prefs;
	Future<SharedPreferences> get _sp async => _prefs ??= await SharedPreferences.getInstance();

	// Guarda el JSON (Map) con timestamp.
	Future<void> setJson(String key, Map<String, dynamic> json) async {
		final prefs = await _sp;
		final entry = CacheEntry(
			data: jsonEncode(json),
			savedAtMillis: DateTime.now().millisecondsSinceEpoch,
		);
		await prefs.setString('$_prefix$key', jsonEncode(entry.toMap()));
	}

	// Lee el JSON si no está vencido por TTL (minutos).
	Future<Map<String, dynamic>?> getJson(String key, {required int ttlMinutes}) async {
		final prefs = await _sp;
		final raw = prefs.getString('$_prefix$key');
		if (raw == null) return null;

		try {
			final map = jsonDecode(raw) as Map<String, dynamic>;
			final entry = CacheEntry.fromMap(map);
			if (entry == null) return null;

			final ageMs = DateTime.now().millisecondsSinceEpoch - entry.savedAtMillis;
			final ttlMs = Duration(minutes: ttlMinutes).inMilliseconds;
			if (ageMs > ttlMs) return null;

			return jsonDecode(entry.data) as Map<String, dynamic>;
		} catch (_) {
			return null;
		}
	}

	// Invalida una clave puntual.
	Future<void> invalidate(String key) async {
		final prefs = await _sp;
		await prefs.remove('$_prefix$key');
	}

	// Limpia todo el caché de la app (solo claves con prefijo).
	Future<void> clearAll() async {
		final prefs = await _sp;
		final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
		for (final k in keys) {
			await prefs.remove(k);
		}
	}
}
