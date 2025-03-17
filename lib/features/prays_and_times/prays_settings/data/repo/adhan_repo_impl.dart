import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:norway_roznama_new_project/core/failure/failure.dart';
import 'package:norway_roznama_new_project/core/util/api_service.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_settings/data/repo/adhan_repo.dart';

class AdhanRepoImpl implements AdhanRepo{
  final DioHelper dioHelper;
  AdhanRepoImpl(this.dioHelper);
  @override
  Future<Either<Failure, Response>> getAdhan() async{
    try{
      var response = await dioHelper.getData(endPoint: 'api/v1/adhan');
      return right(response);
    }catch(e){ 
      if(e is DioException){
        return left(ServerFailure.fromDioError(e));
      }
      else {
        return left(ServerFailure(e.toString()));
      }
    }
  }
}