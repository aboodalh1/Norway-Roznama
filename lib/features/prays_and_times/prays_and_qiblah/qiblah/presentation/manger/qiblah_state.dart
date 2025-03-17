part of 'qiblah_cubit.dart';

sealed class QiblahState {}

final class QiblahInitial extends QiblahState {}

final class GetQiblahLoading extends QiblahState{}
final class GetQiblahFailure extends QiblahState{
  final String error;

  GetQiblahFailure({required this.error});
}
final class GetQiblahSuccess extends QiblahState{
  final String message;

  GetQiblahSuccess({required this.message});
}
