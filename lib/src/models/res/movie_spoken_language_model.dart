class SpokenLanguageModel {
  final String? englishName;
  final String? iso6391;
  final String? name;

  const SpokenLanguageModel({
    this.englishName,
    this.iso6391,
    this.name,
  });

  factory SpokenLanguageModel.fromJson(Map<String, dynamic> json) {
    return SpokenLanguageModel(
      englishName: json['english_name'] as String?,
      iso6391: json['iso_639_1'] as String?,
      name: json['name'] as String?,
    );
  }
}