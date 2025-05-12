import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:norway_roznama_new_project/core/failure/failure.dart';

abstract class MonthlyTimingRepo{

    Future<Either<Failure,Response>> getMonthlyTiming({required double lat,required int year,required int month,required double long});

}