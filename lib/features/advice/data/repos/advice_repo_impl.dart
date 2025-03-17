import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/util/api_service.dart';
import 'advice_repo.dart';

class AdviceRepoImpl implements AdviceRepo{
  DioHelper dioHelper;
  AdviceRepoImpl(this.dioHelper);
  @override
  Future<Either<Failure, Response>> sentAdvice({required String name, required String email, required String message}) async{
      try{
          var response = await dioHelper.postData(endPoint: 'api/v1/advice', data: {
            "title": name,
            "content": message,
            "contact_info": "{\"email\":\"$email\"}"
          });
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