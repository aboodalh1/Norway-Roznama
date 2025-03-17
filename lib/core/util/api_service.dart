import 'package:dio/dio.dart';

class DioHelper {
  final baseUrl = 'https://srv709257.hstgr.cloud:444/';
  final Dio dio;
  static String ? _token;
  DioHelper(this.dio);

  Future<Response> getData({
    required String endPoint,
    String ? link,
    Map<String, dynamic>? query,
    String lang = "en",
    String? contentType,
    String? accept,
  }) async {
    Map<String, String> headers = {
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers.addAll({'Authorization': 'Bearer $_token'});
    }
    return await dio
        .get(link??'$baseUrl$endPoint',
        queryParameters: query,
        data: query,
        options: Options(
          contentType: 'Application/json',
          validateStatus: (status){return status != null && status < 500;},
          receiveDataWhenStatusError: true,
          extra: query,
          headers: headers,
        ));
  }


  Future<Response> postData(
      {required String endPoint,
        required var data,
        String? token}) async {
    Map<String, String> headers = {
      'Accept':'application/json'

    };
    if (_token != null) {

      headers.addAll({'Authorization': 'Bearer $_token'});
    }
    return dio.post('$baseUrl$endPoint',
        data: data,
        options: Options(
            receiveDataWhenStatusError: true,
            headers: headers));
  }
  Future<Response> putData(
      {required String endPoint,
        required Map<String, dynamic> data,
        String lang = "en",
        String? token}) async {

    dio.options.headers = {
      'Accept': 'application/json',
      'lang': lang,
      'Authorization': 'Bearer $token'
    };
    return await dio.put('$baseUrl$endPoint', data: data);
  }

  Future<Response> deleteData(

      {required String endPoint,
        Map<String, dynamic>? query,
      }) async {

    dio.options.headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token'
    };

    return await dio.delete('$baseUrl$endPoint',
        queryParameters: query,
        options: Options(
        ));
  }
}
