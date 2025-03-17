import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  int currentIndex = 0;

  TextEditingController searchController = TextEditingController();
  String selectedSection = "";
  int selectedSectionId=0;
  bool isSectionSelected = false;
  void changeSearchEnabled(bool value){
    isSectionSelected = value;
    emit(ChangeSearchState());
  }
  final GlobalKey searchBarKey = GlobalKey();



  void changeNavBar(int index){
    currentIndex=index;
    emit(ChangeNavBarScreen());
  }
}
