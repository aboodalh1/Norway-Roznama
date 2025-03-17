import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/failure/failure.dart';
import '../../../../core/util/api_service.dart';
import 'articles_repo.dart';

class ArticlesRepoImpl implements ArticlesRepo{
  ArticlesRepoImpl(this.dioHelper);
  DioHelper dioHelper;
  @override
  Future<Either<Failure, Response>> getArticleDetails({required num id}) async{
    try{
    var response = await dioHelper.getData(endPoint: 'api/v1/blogs/$id');
    return right(response);
    }catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Response>> getArticles({int ?sectionId,String? title,required num number}) async{
    try{
      var response = await dioHelper.getData(endPoint: 'api/v1/blogs',query: title!=null && sectionId!=null?{
        "section_id":sectionId,
        "title": title,
        'perPage':5}:
      sectionId!=null?{
        "section_id":sectionId,
        "perPage": 5
      }:title!=null?{
        "title":title,
        "perPage":5
      }:{
        "perPage":5
      });
      return right(response);
    }catch (e) {
      print(e.toString());
      if (e is DioException) {

        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Response>> searchForArticle({required String text}) async{
    try{
      var response = await dioHelper.getData(endPoint: 'endPoint');
      return right(response);
    }catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Response>> getMoreArticles({required path}) async{
    try{
      var response = await dioHelper.getData(link:path,endPoint: 'api/v1/blogs',query: {'perPage':5});
      return right(response);
    }catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
    }

  @override
  Future<Either<Failure, Response>> getSections({required num number}) async{
    try{
      var response = await dioHelper.getData(endPoint: 'api/v1/sections',query:  {'perPage':10});
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

  @override
  Future<Either<Failure, Response>> searchForSection({required String text}) {
    // TODO: implement searchForSections
    throw UnimplementedError();
  }
}