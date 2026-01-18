import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:norway_roznama_new_project/core/util/Is24Format.dart';
import 'package:norway_roznama_new_project/features/halal_food/data/repos/halal_repo_impl.dart';
import 'package:norway_roznama_new_project/features/monthly_timing/data/repos/monthly_timing_repo_impl.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/qiblah/data/repos/qiblah_repo_impl.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/repo/adhan_repo_impl.dart';

import '../../features/advice/data/repos/advice_repo_impl.dart';
import '../../features/articles_and_stickers/data/repos/articles_repo_impl.dart';
import '../../features/articles_and_stickers/data/repos/stickers_repos/stickers_repo_impl.dart';
import '../../features/prays_and_times/prays_and_qiblah/data/repos/prays_repo_impl.dart';
import 'api_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // Bypass SSL certificate verification
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    },
  );

  // Add retry interceptor for connection errors
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            (error.type == DioExceptionType.unknown &&
                (error.message?.contains('SocketException') == true ||
                 error.message?.contains('connection abort') == true ||
                 error.message?.contains('Software caused connection abort') == true))) {
          final retryCount = (error.requestOptions.extra['retryCount'] as int?) ?? 0;
          const maxRetries = 3;
          
          if (retryCount < maxRetries) {
            error.requestOptions.extra['retryCount'] = retryCount + 1;
            final delay = Duration(milliseconds: 1000 * (retryCount + 1));
            await Future.delayed(delay);
            try {
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              if (e is DioException) {
                return handler.next(e);
              }
              return handler.next(error);
            }
          }
        }
        return handler.next(error);
      },
    ),
  );

  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: false,
      maxWidth: 120,
    ),
  );

  getIt.registerSingleton(DioHelper(dio));
  getIt.registerSingleton<ArticlesRepoImpl>(
      ArticlesRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<HalalRepoImpl>(HalalRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<StickersRepoImpl>(
      StickersRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<AdviceRepoImpl>(
      AdviceRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<PraysRepoImpl>(PraysRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<QiblahRepoImpl>(
      QiblahRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<AdhanRepoImpl>(AdhanRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton<MonthlyTimingRepoImpl>(
      MonthlyTimingRepoImpl(getIt.get<DioHelper>()));
  getIt.registerSingleton(Is24Format());
}
