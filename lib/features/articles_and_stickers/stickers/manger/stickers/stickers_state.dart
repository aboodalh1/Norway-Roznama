part of 'stickers_cubit.dart';

sealed class StickersState {}

final class StickersInitial extends StickersState {}

final class GetStickersLoading extends StickersState {}

final class GetStickersSuccess extends StickersState {
  final String message;

  GetStickersSuccess({required this.message});
}

final class GetStickersError extends StickersState {
  final String error;

  GetStickersError({required this.error});
}

class StickersLoaded extends StickersState {
  final bool isFinish;

  StickersLoaded(this.isFinish);
}

class StickerSavedSuccess extends StickersState {
  final String message;

  StickerSavedSuccess({required this.message});
}
class StickerSaveLoading extends StickersState {

}

class StickerSavedFailure extends StickersState {
  final String error;

  StickerSavedFailure({required this.error});
}

class SelectSticker extends StickersState {}

class StickersLoadingState extends StickersState {}
class StickerSuccessState extends StickersState {}

class StickerErrorState extends StickersState {
  final String error;

  StickerErrorState({required this.error});

}
class MoreStickersLoadingState extends StickersState {}
class MoreStickerSuccessState extends StickersState {}

class MoreStickerErrorState extends StickersState {
  final String error;

  MoreStickerErrorState({required this.error});
}
