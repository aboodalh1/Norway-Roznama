import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/failure/failure.dart';
abstract class ArticlesRepo{

  Future<Either<Failure,Response>>getArticles({int ?sectionId,String? title,required num number});
  Future<Either<Failure,Response>>getSections({required num number});
  Future<Either<Failure,Response>>getMoreArticles({required path});
  Future<Either<Failure,Response>>getArticleDetails({required num id});
  Future<Either<Failure,Response>>searchForArticle({required String text});
  Future<Either<Failure,Response>>searchForSection({required String text});

}