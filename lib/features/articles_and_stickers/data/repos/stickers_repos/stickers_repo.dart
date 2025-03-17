import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/failure/failure.dart';

abstract class StickersRepo{
  Future<Either<Failure,Response>>getStickers({required int perPage,required int catId,int? page,String ? name});
  Future<Either<Failure,Response>>getMoreStickers({required String path});
  Future<Either<Failure,Response>>getCategories({required int perPage,int? page,String ? name});
  Future<Either<Failure,Response>>getCategoriesById({required int id});
  Future<Either<Failure,Response>>getStickerById({required int id});
}