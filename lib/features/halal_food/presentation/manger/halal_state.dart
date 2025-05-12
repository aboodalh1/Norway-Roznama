part of 'halal_cubit.dart';

sealed class HalalState {}

final class HalalInitial extends HalalState {}

final class HalalLoading extends HalalState{}
final class HalalSuccess extends HalalState{}
final class HalalFailure extends HalalState{
  final String error;

  HalalFailure({required this.error});

}
