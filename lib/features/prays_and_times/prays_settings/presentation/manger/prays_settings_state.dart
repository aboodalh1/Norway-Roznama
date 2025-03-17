part of 'prays_settings_cubit.dart';

sealed class PraysSettingsState {}

final class PraysSettingsInitial extends PraysSettingsState {}

final class ChangeExpandState extends PraysSettingsState {}

final class ExpandFaredaState extends PraysSettingsState {}

final class ChangeSliderValueState extends PraysSettingsState {}

final class ChangeFaredaState extends PraysSettingsState {}

final class ChangeSwitchState extends PraysSettingsState {}

final class ChangeReaderState extends PraysSettingsState {}

final class GetAdhanLoading extends PraysSettingsState {}

final class GetAdhanFailure extends PraysSettingsState {
  final String error;

  GetAdhanFailure({required this.error});
}

final class AdhanDownloadSuccess extends PraysSettingsState {
  final String message;

  AdhanDownloadSuccess({required this.message});
}

final class AdhanDownloadFailure extends PraysSettingsState {
  final String error;

  AdhanDownloadFailure({required this.error});
}

final class AdhanDownloadLoading extends PraysSettingsState {}

final class GetAdhanSuccess extends PraysSettingsState {
  final AdhanModel adhanModel;
  final player = AudioPlayer();

  GetAdhanSuccess({required this.adhanModel});
}
