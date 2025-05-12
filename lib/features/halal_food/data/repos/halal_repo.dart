
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/failure/failure.dart';

abstract class HalalRepo{
  Future<Either<Failure,Response>>checkHalal({required String barcode});
}