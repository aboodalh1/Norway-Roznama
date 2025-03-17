part of 'categories_cubit.dart';

final class CategoriesState {}

final class CategoriesInitial extends CategoriesState {}

final class CategoriesLoadingState extends CategoriesState{}
final class CategoriesSuccessState extends CategoriesState{
  final String message;

  CategoriesSuccessState({required this.message});

}
final class CategoriesErrorState extends CategoriesState{
  final String error;

  CategoriesErrorState({required this.error});
}
final class MoreCategoriesLoadingState extends CategoriesState{}
final class MoreCategoriesSuccessState extends CategoriesState{
  final String message;

  MoreCategoriesSuccessState({required this.message});

}
final class MoreCategoriesErrorState extends CategoriesState{
  final String error;

  MoreCategoriesErrorState({required this.error});
}
final class EndOfCategories extends CategoriesState{
  final String error;

  EndOfCategories({required this.error});
}