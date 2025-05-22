import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:norway_roznama_new_project/core/failure/failure.dart';
import 'package:norway_roznama_new_project/core/util/api_service.dart';
import 'monthly_timin_repo.dart';

class MonthlyTimingRepoImpl implements MonthlyTimingRepo{
  MonthlyTimingRepoImpl(this.dioHelper);
  DioHelper dioHelper;
  @override
  Future<Either<Failure, Response>> getMonthlyTiming({required double lat,required int year,required int month, required double long}) async{
    try{
      var response = await dioHelper.getData(endPoint:  'api/v1/prayers/month',query: {
        'latitude': lat,
        'longitude': long,
        'date': '$year-$month'
      });
      return right(response);
    }catch(e){
      if(e is DioException){
        return left(ServerFailure.fromDioError(e));
      }
      else{
        return left(ServerFailure(e.toString()));
    }}
  }
}