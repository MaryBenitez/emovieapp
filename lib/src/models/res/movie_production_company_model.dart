class ProductionCompanyModel {
  final int? id;
  final String? logoPath;
  final String? name;
  final String? originCountry;

  const ProductionCompanyModel({
    this.id,
    this.logoPath,
    this.name,
    this.originCountry,
  });

  factory ProductionCompanyModel.fromJson(Map<String, dynamic> json) {
    return ProductionCompanyModel(
      id: json['id'] as int?,
      logoPath: json['logo_path'] as String?,
      name: json['name'] as String?,
      originCountry: json['origin_country'] as String?,
    );
  }
}