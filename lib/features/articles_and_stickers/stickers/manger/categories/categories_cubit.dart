import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/data/repos/stickers_repos/stickers_repo.dart';

import '../../../data/model/blogs_model.dart';
import '../../../data/model/stickers/categories_model.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this.stickersRepo) : scrollController = ScrollController(),
        super(CategoriesInitial()){
    getCategories(page: 5);
    scrollController.addListener(_onScroll);
  }
  StickersRepo stickersRepo;
  num page = 0;

  final ScrollController scrollController;
  CategoriesModel categoriesModel = CategoriesModel(
      links: Links(first: '', last: '', prev: '', next: ''),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [],
          perPage: 0,
          to: 0,
          total: 0,
          path: ''),
      data: []);
  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (page == 1 && categoriesModel.links.next.isNotEmpty) {
        getMoreCategories(path: categoriesModel.links.next);
      } else {
        if (newCategoriesModel.links.next.isNotEmpty) {

          getMoreCategories(path: newCategoriesModel.links.next);
        }
      }
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels == 0) {
          // emit(StickersLoaded(false)); // At the top
        } else {
          // emit(StickersLoaded(true)); // At the bottom
        }
      } else {
        // emit(StickersLoaded(false)); // More items to scroll
      }
    }
  }
  @override
  Future<void> close() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    return super.close();
  }

  Future<void> getCategories({required page}) async {
    emit(CategoriesLoadingState());
    var result = await stickersRepo.getCategories(perPage: page);
    result.fold((l) {
      emit(CategoriesErrorState(error: l.errMessage));
    }, (r) {
      categoriesModel = CategoriesModel.fromJson(r.data);
      this.page = categoriesModel.meta.currentPage;
      emit(CategoriesSuccessState(message: ''));
    });
  }


  CategoriesModel newCategoriesModel = CategoriesModel(
      data: [],
      links: Links(first: '', last: '', prev: '', next: ' '),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [],
          path: '',
          perPage: 0,
          to: 0,
          total: 0));

  Future<void> getMoreCategories({required String path}) async {
    emit(MoreCategoriesLoadingState());
    final result = await stickersRepo.getMoreStickers(path: path);
    result.fold((failure) {
      emit(MoreCategoriesErrorState(error: failure.errMessage));
    }, (response) {
      try {
        newCategoriesModel = CategoriesModel.fromJson(response.data);
        page = newCategoriesModel.meta.currentPage;
        if (newCategoriesModel.data.isEmpty) {
          emit(EndOfCategories(error: ''));
        } else {
          categoriesModel.data.addAll(newCategoriesModel.data);
          emit(MoreCategoriesSuccessState(message: ''));
        }
      } catch (e) {
        emit(MoreCategoriesErrorState(error: "حدث خطأ ما، حاول مجدداً"));
      }
    });
  }

}
