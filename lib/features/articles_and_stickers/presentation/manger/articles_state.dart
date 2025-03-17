part of 'articles_cubit.dart';

sealed class ArticlesState {}

final class ArticlesInitial extends ArticlesState {}

final class ArticlesLoaded extends ArticlesState {
  final bool isFinish;

  ArticlesLoaded(this.isFinish);
}
final class GetArticlesLoading extends ArticlesState {}

final class GetArticlesSuccess extends ArticlesState {
  final String message;

  GetArticlesSuccess({required this.message});
}
final class GetSpecificArticlesSuccess extends ArticlesState {

}

final class GetArticlesError extends ArticlesState {
  final String error;

  GetArticlesError({required this.error});
}

final class SearchArticlesLoading extends ArticlesState {}

final class SearchArticlesSuccess extends ArticlesState {
  final String message;

  SearchArticlesSuccess({required this.message});
}

final class SearchArticlesError extends ArticlesState {
  final String error;

  SearchArticlesError({required this.error});
}

final class NoArticlesState extends ArticlesState {}

final class GetMoreArticlesLoading extends ArticlesState {}

final class GetMoreArticlesSuccess extends ArticlesState {
  final String message;

  GetMoreArticlesSuccess({required this.message});

}

final class GetMoreArticlesFailure extends ArticlesState {
  final String error;

  GetMoreArticlesFailure({required this.error});

}

final class GetMoreSpecificArticlesLoading extends ArticlesState {}

final class GetMoreSpecificArticlesSuccess extends ArticlesState {
  final String message;

  GetMoreSpecificArticlesSuccess({required this.message});

}

final class GetMoreSpecificArticlesFailure extends ArticlesState {
  final String error;

  GetMoreSpecificArticlesFailure({required this.error});

}

final class GetSectionsLoading extends ArticlesState{}

final class GetSectionsFailure extends ArticlesState{
  final String error;

  GetSectionsFailure({required this.error});
}
final class GetSectionsSuccess extends ArticlesState{
  final String message;

  GetSectionsSuccess({required this.message});
}