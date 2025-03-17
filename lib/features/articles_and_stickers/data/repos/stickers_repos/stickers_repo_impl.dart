import 'package:dartz/dartz.dart';

import 'package:dio/dio.dart';

import 'package:norway_roznama_new_project/features/articles_and_stickers/data/repos/stickers_repos/stickers_repo.dart';

import '../../../../../core/failure/failure.dart';

import '../../../../../core/util/api_service.dart';

class StickersRepoImpl implements StickersRepo {
  DioHelper dioHelper;

  StickersRepoImpl(this.dioHelper);

  @override
  Future<Either<Failure, Response>> getStickers(
      {required int perPage,
      int? page,
      required int catId,
      String? name}) async {
    try {
      var response = await dioHelper.getData(
          endPoint: 'api/v1/stickers',
          query: {'perPage': 10, 'category_id': catId, 'name': name ?? ''});
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Response>> getCategories(
      {required int perPage, int? page, String? name}) async {
    try {
      var response = await dioHelper.getData(
          endPoint: 'api/v1/categories',
          query: {'page': page, 'perPage': perPage});
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Response>> getCategoriesById({required int id}) async {
    try {
      var response = await dioHelper.getData(endPoint: 'api/v1/stickers/$id');
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Response>> getStickerById({required int id}) async {
    try {
      var response = await dioHelper.getData(endPoint: 'api/v1/categories/$id');
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Response>> getMoreStickers(
      {required String path}) async {
    try {
      var response = await dioHelper.getData(
          link: path, endPoint: 'api/v1/stickers', query: {'perPage': 5});
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(ServerFailure.fromDioError(e));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}
