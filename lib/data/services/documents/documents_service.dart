import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:cleaning_service_driver/core/models/response.dart';
import 'package:cleaning_service_driver/data/models/documents/business_document.dart';
part 'documents_service.g.dart';

@RestApi()
abstract class DocumentsService {
  factory DocumentsService(Dio dio, {String baseUrl}) = _DocumentsService;
  @GET('/company/documents')
  Future<ApiResponse<DocumentPage>> list(
      @Query('page') int page,
      @Query('limit') int limit,
      @Query('search') String? search,
      @Query('category') String? category);
  @GET('/company/documents/{id}/download')
  @DioResponseType(ResponseType.bytes)
  Future<List<int>> download(@Path('id') String id);
}
