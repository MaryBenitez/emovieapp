class GeneralModel<T> {
  final int? statusCode;
  final String? statusMessage;
  final bool? success;
  final T? dates;
  final int? page;
  final T? results;
  final int? totalPages;
  final int? totalResults;

  GeneralModel({
    this.statusCode,
    this.statusMessage,
    this.success,
    this.dates,
    this.page,
    this.results,
    this.totalPages,
    this.totalResults
  });

  // Ajusta el método fromMap para aceptar un solo argumento
  factory GeneralModel.fromMap(Map<String, dynamic> map) {
    return GeneralModel(
      statusCode: map['status_code'] ?? 0,
      statusMessage: map['status_message'] ?? '',
      success: map['success'] ?? false,
      dates: map['dates'] != null ? map['results'] as T : null,
      page: map['page'] ?? 0,
      results: map['results'] != null ? map['results'] as T : null,
      totalPages: map['total_pages'] ?? 0,
      totalResults: map['total_results'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {

    final map = <String, dynamic>{
      'status_code': statusCode,
      'status_message': statusMessage,
      'success': success,
      'dates': dates,
      'page': page,
      'results': results,
      'total_pages': totalPages,
      'total_results': totalResults,
    };
    map.removeWhere((k, v) => v == null);
    return map;
  }
}
