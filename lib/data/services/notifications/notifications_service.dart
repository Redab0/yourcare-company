import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'notifications_service.g.dart';

@RestApi()
class NotificationsService {
  factory NotificationsService(Dio dio, {String baseUrl}) =
      _NotificationsService;
}
