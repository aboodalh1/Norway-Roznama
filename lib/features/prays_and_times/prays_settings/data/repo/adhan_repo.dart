import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/failure/failure.dart';

abstract class AdhanRepo{

  Future<Either<Failure,Response>> getAdhan();
}