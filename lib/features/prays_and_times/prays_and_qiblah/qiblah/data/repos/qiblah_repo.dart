import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/failure/failure.dart';

abstract class QiblahRepo {

  Future<Either<Failure,Response>> getQiblah();
}