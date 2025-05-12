import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/failure/failure.dart';


abstract class PraysRepo{

  Future<Either<Failure,Response>> getPrayersTimes({required double lat,required double long});

}
