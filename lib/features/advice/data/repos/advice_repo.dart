import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/failure/failure.dart';

abstract class AdviceRepo{

  Future<Either<Failure,Response>>sentAdvice({
    required String name,
    required String email,
    required String message,
});
}