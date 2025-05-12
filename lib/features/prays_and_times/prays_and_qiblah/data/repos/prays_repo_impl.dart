import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/data/repos/prays_repo.dart';
import '../../../../../core/failure/failure.dart';
import '../../../../../core/util/api_service.dart';

class PraysRepoImpl implements PraysRepo {
  PraysRepoImpl(this.dioHelper);
  DioHelper dioHelper;
  @override
  Future<Either<Failure, Response>> getPrayersTimes(
      {required double lat, required double long}) async {
    try {
      var response = await dioHelper.getData(
        endPoint: 'api/v1/prayers/day',
        query: {
          'latitude': lat,
          'longitude': long,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now())
        },
      );

      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      } else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}
