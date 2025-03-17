part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}
final class ChangeSearchState extends HomeState{}
final class ChangeNavBarScreen extends HomeState{}
