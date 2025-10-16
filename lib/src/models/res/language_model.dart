class LanguageModel {
  final String code;
  final String name;
  final String flag;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.flag,
  });

  // Factory para crear desde código de idioma
  factory LanguageModel.fromCode(String languageCode) {
    final parts = languageCode.split('-');
    final language = parts[0];
    final country = parts.length > 1 ? parts[1] : '';

    return LanguageModel(
      code: languageCode,
      name: _getLanguageName(language, country),
      flag: _getFlag(country),
    );
  }

  // Mapeo de códigos a nombres
  static String _getLanguageName(String language, String country) {
    final Map<String, String> languageNames = {
      'es': country == 'MX' ? 'Español (México)' : 'Español',
      'en': country == 'US' ? 'English (US)' : 'English',
      'fr': country == 'CA' ? 'Français (Canada)' : 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': country == 'BR' ? 'Português (Brasil)' : 'Português',
      'ja': '日本語',
      'ko': '한국어',
      'zh': country == 'CN' ? '中文 (简体)' : '中文 (繁體)',
      'ru': 'Русский',
      'ar': 'العربية',
      'hi': 'हिन्दी',
      'th': 'ไทย',
      'vi': 'Tiếng Việt',
      'tr': 'Türkçe',
      'pl': 'Polski',
      'nl': 'Nederlands',
      'sv': 'Svenska',
      'da': 'Dansk',
      'no': 'Norsk',
      'fi': 'Suomi',
      'cs': 'Čeština',
      'hu': 'Magyar',
      'ro': 'Română',
      'bg': 'Български',
      'hr': 'Hrvatski',
      'sk': 'Slovenčina',
      'sl': 'Slovenščina',
      'et': 'Eesti',
      'lv': 'Latviešu',
      'lt': 'Lietuvių',
      'el': 'Ελληνικά',
      'he': 'עברית',
      'fa': 'فارسی',
      'ur': 'اردو',
      'bn': 'বাংলা',
      'ta': 'தமிழ்',
      'te': 'తెలుగు',
      'ml': 'മലയാളം',
      'kn': 'ಕನ್ನಡ',
      'mr': 'मराठी',
      'pa': 'ਪੰਜਾਬੀ',
      'gu': 'ગુજરાતી',
      'or': 'ଓଡ଼ିଆ',
      'as': 'অসমীয়া',
      'id': 'Bahasa Indonesia',
      'ms': 'Bahasa Melayu',
      'tl': 'Filipino',
    };

    return languageNames[language] ?? language.toUpperCase();
  }

  // Mapeo de países a flags
  static String _getFlag(String country) {
    final Map<String, String> flags = {
      'ES': '🇪🇸', 'MX': '🇲🇽', 'US': '🇺🇸', 'GB': '🇬🇧', 'CA': '🇨🇦',
      'FR': '🇫🇷', 'DE': '🇩🇪', 'IT': '🇮🇹', 'PT': '🇵🇹', 'BR': '🇧🇷',
      'JP': '🇯🇵', 'KR': '🇰🇷', 'CN': '🇨🇳', 'TW': '🇹🇼', 'HK': '🇭🇰',
      'RU': '🇷🇺', 'AE': '🇦🇪', 'SA': '🇸🇦', 'IN': '🇮🇳', 'TH': '🇹🇭',
      'VN': '🇻🇳', 'TR': '🇹🇷', 'PL': '🇵🇱', 'NL': '🇳🇱', 'SE': '🇸🇪',
      'DK': '🇩🇰', 'NO': '🇳🇴', 'FI': '🇫🇮', 'CZ': '🇨🇿', 'HU': '🇭🇺',
      'RO': '🇷🇴', 'BG': '🇧🇬', 'HR': '🇭🇷', 'SK': '🇸🇰', 'SI': '🇸🇮',
      'EE': '🇪🇪', 'LV': '🇱🇻', 'LT': '🇱🇹', 'GR': '🇬🇷', 'IL': '🇮🇱',
      'IR': '🇮🇷', 'BD': '🇧🇩', 'PH': '🇵🇭', 'ID': '🇮🇩', 'MY': '🇲🇾',
      'SG': '🇸🇬', 'AU': '🇦🇺', 'NZ': '🇳🇿', 'IE': '🇮🇪', 'ZA': '🇿🇦',
    };

    return flags[country] ?? '🌍';
  }

  String get displayName => '$flag $name';

  @override
  String toString() => displayName;
}