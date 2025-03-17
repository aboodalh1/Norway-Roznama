part of 'advice_cubit.dart';

sealed class AdviceState {}

final class AdviceInitial extends AdviceState {}

final class SentAdviceLoading extends AdviceState {}

final class SentAdviceSuccess extends AdviceState {
  final String message;

  SentAdviceSuccess({required this.message});
}
final class SentAdviceFailure extends AdviceState{
  final String error;
  SentAdviceFailure({required this.error});
}
final class SentValidationFailure extends AdviceState{
  final String error;
  SentValidationFailure({required this.error});
}