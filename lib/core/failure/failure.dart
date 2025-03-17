import 'package:dio/dio.dart';

abstract class Failure {
  final String errMessage;
  const Failure(this.errMessage);
}

class ServerFailure extends Failure {
  ServerFailure(super.errMessage);
  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('اتصال بالانترنت ضعيف');
      case DioExceptionType.sendTimeout:
        return ServerFailure('Send timeout with ApiServer');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive timeout with ApiServer');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioError.response!.statusCode, dioError.response!.data);
      case DioExceptionType.cancel:
        return ServerFailure('Request to ApiServer was canceled');
      case DioExceptionType.unknown:
        if(dioError.message==null){return ServerFailure("حدث خطأ في المخدم");}
        if (dioError.message!.contains('SocketException')) {
          return ServerFailure('لا يوجد اتصال بالانترنت');
        }
        return ServerFailure('حدث خطأ ما، أعد المحاولة');
      default:
        return ServerFailure('الرجاء التأكد من الاتصال بالانترنت');
    }
  }
  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if(statusCode==401) {
      return ServerFailure('انتهت مدة الجلسة');}
    if (statusCode == 400 || statusCode == 403||statusCode==422) {
      return ServerFailure('${response['message'] ?? "خطأ بالاتصال بالانترنت"} ');

    } else if (statusCode == 404) {
      return ServerFailure(response['message']);}
    else if (statusCode == 405) {
      return ServerFailure(response['message'] ?? 'حدث خطأ ما');
    } else if (statusCode == 500) {
      return ServerFailure('حدث خطأ بالمخدم');
    } else {
      return ServerFailure(response['message'] ?? 'حدث خطأ ما');
    }
  }
}
