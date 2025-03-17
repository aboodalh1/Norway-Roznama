import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:norway_roznama_new_project/core/util/api_service.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/qiblah/data/repos/qiblah_repo.dart';

import '../../../../../../core/failure/failure.dart';
import '../../../../../../core/util/constant.dart';

class QiblahRepoImpl implements QiblahRepo{
  DioHelper dioHelper;
  QiblahRepoImpl(this.dioHelper);
  @override
  Future<Either<Failure, Response>> getQiblah() async{
    try{
      var response = await dioHelper.getData(
        link: 'https://api.aladhan.com/v1/qibla/$latitude/$longitude/compass', endPoint: '',
      );
      return right(response);
    }catch(e){
      if(e is DioException){
        return left(ServerFailure.fromDioError(e));
      }
      else{
        return left(ServerFailure(e.toString()));
      }
    }
  }

}