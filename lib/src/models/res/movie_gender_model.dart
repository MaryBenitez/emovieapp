class GenreModel {
  final int? id;
  final String? name;

  const GenreModel({
    this.id,
    this.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
    );
  }
}