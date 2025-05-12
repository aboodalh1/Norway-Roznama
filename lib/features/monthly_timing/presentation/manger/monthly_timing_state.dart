part of 'monthly_timing_cubit.dart';

sealed class MonthlyTimingState {}

final class MonthlyTimingInitial extends MonthlyTimingState {}

final class GetMonthlyTimingLoading extends MonthlyTimingState {}

final class GetMonthlyTimingFailure extends MonthlyTimingState {
  final String error;

  GetMonthlyTimingFailure({required this.error});
}

final class GetMonthlyTimingSuccess extends MonthlyTimingState {}

final class SavePdfLoading extends MonthlyTimingState {}

final class SavePdfSuccess extends MonthlyTimingState {
  final String message;

  SavePdfSuccess({required this.message});
}

final class SavePdfFailure extends MonthlyTimingState {
  final String error;

  SavePdfFailure({required this.error});
}
final class ChangeMonth extends MonthlyTimingState{}