// paginated_data.dart
import 'package:json_annotation/json_annotation.dart';

part 'page_wrapper.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PaginatedData<T> {
  final List<T> docs;
  final int totalDocs;
  final int limit;
  final int totalPages;
  final int page;
  final int pagingCounter;
  final bool hasPrevPage;
  final bool hasNextPage;
  final int? prevPage;
  final int? nextPage;

  PaginatedData({
    required this.docs,
    required this.totalDocs,
    required this.limit,
    required this.totalPages,
    required this.page,
    required this.pagingCounter,
    required this.hasPrevPage,
    required this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  /// Uses the generated helper, passing the element-level converter directly.
  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedDataFromJson(json, fromJsonT);

  /// Uses the generated helper, passing the element-level converter directly.
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedDataToJson(this, toJsonT);
}
