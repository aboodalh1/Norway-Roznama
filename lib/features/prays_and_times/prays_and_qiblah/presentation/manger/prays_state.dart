part of 'prays_cubit.dart';

sealed class PraysState {}

final class PraysInitial extends PraysState {}

final class ChangeExpandState extends PraysState {}

final class ExpandFaredaState extends PraysState {}

final class ChangeSliderValueState extends PraysState {}

final class ChangeFaredaState extends PraysState {}

final class GetPraysTimesLoading extends PraysState {}

final class GetPrayersTimesSuccess extends PraysState {
  final String message;

  GetPrayersTimesSuccess({required this.message});
}

final class GetLocalPrayersTimesSuccess extends PraysState {}

final class GetPrayersTimesError extends PraysState {
  final String error;

  GetPrayersTimesError({required this.error});
}

final class SavePrayerTimesPdfLoadingState extends PraysState {}

final class SavePrayerTimesPdfSuccessState extends PraysState {
  final String message;

  SavePrayerTimesPdfSuccessState({required this.message});
}

final class SavePrayerTimesPdfFailureState extends PraysState {
  final String error;

  SavePrayerTimesPdfFailureState({required this.error});
}

final class ChangeSwitchState extends PraysState {}

final class ChangeReaderState extends PraysState {}

class LocationMissedState extends PraysState {
  final String message;

  LocationMissedState({required this.message});
}

class LocationLoadingState extends PraysState {}

class LocationFailureState extends PraysState {}

/// Emitted when a prayer sub-reminder slot config changes.
final class ChangeReminderState extends PraysState {}
