import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/util/api_service.dart';
import 'halal_repo.dart';

class HalalRepoImpl implements HalalRepo{

  DioHelper dioHelper;

  HalalRepoImpl(this.dioHelper);

  @override
  Future<Either<Failure, Response>> checkHalal({required String barcode}) async {
    try {
      var response = await dioHelper.getData(
          endPoint: 'api/v1/halalfood/check',
          query: {'barcode': barcode});
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }


}