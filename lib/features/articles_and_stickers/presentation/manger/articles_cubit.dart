import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/blogs_model.dart';
import '../../data/model/sections_model.dart';
import '../../data/repos/articles_repo.dart';

part 'articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  ArticlesCubit(this.articlesRepo)
      : scrollController = ScrollController(),
        super(ArticlesInitial()) {
    scrollController.addListener(_onScroll);
  }

  ArticlesRepo articlesRepo;
  final ScrollController scrollController;

  bool isFinish = false;

  void _onScroll() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (page == 1 && allBlogsModel.links.next.isNotEmpty) {
        getMoreArticles(path: allBlogsModel.links.next);
      } else {
        if (newBlogsModel.links.next.isNotEmpty) {
          getMoreArticles(path: newBlogsModel.links.next);
        }
      }
    }
  }

  @override
  Future<void> close() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    return super.close();
  }

  AllBlogsModel allBlogsModel = AllBlogsModel(
      data: [],
      links: Links(first: '', last: '', prev: '', next: ''),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [],
          perPage: 0,
          to: 0,
          total: 0,
          path: ''));
  num page = 0;
  bool isLoadingMore = false;

  Future<void> getArticles(
      {int? sectionId, String? title, required num number}) async {
    emit(GetArticlesLoading());
    final result = sectionId != null && title!=null
        ? await articlesRepo.getArticles(sectionId: sectionId, number: number,title: title)
        : sectionId != null? await articlesRepo.getArticles(number: number,sectionId: sectionId):
        title!=null? await articlesRepo.getArticles(number: number,title: title):
    await articlesRepo.getArticles(number: number);
    result.fold((failure) {
      emit(GetArticlesError(error: failure.errMessage));
    }, (response) {
      try {
       if(sectionId==null){
       allBlogsModel = AllBlogsModel.fromJson(response.data);
        page = allBlogsModel.meta.currentPage;
       }
       else{
         allBlogsModelSpecific = AllBlogsModel.fromJson(response.data);
         specificPage = allBlogsModelSpecific.meta.currentPage;
       }
        if (allBlogsModel.data.isEmpty) {
          emit(NoArticlesState());
        } else {
          sectionId!=null?emit(GetSpecificArticlesSuccess()):
          title!=null?emit(GetSpecificArticlesSuccess()):
          emit(GetArticlesSuccess(message: 'تم تحميل المقالات بنجاح'));
        }
      } catch (e) {
        emit(GetArticlesError(error: "حدث خطأ ما، حاول مجدداً"));
      }
    });
  }

  AllBlogsModel newBlogsModel = AllBlogsModel(
      data: [],
      links: Links(first: '', last: '', prev: '', next: ''),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [
            Links(first: 'first', last: 'last', prev: 'prev', next: 'next')
          ],
          perPage: 0,
          to: 0,
          total: 0,
          path: ''));

  Future<void> getMoreArticles({required String path}) async {
    emit(GetMoreArticlesLoading());
    final result = await articlesRepo.getMoreArticles(path: path);
    result.fold((failure) {
      emit(GetMoreArticlesFailure(error: failure.errMessage));
    }, (response) {
      try {
        newBlogsModel = AllBlogsModel.fromJson(response.data);
        page = newBlogsModel.meta.currentPage;
        if (newBlogsModel.data.isEmpty) {
          emit(NoArticlesState());
        } else {
          allBlogsModel.data.addAll(newBlogsModel.data);
          emit(GetMoreArticlesSuccess(message: 'تم تحميل المقالات بنجاح'));
        }
      } catch (e) {
        emit(GetMoreArticlesFailure(error: "حدث خطأ ما، حاول مجدداً"));
      }
    });
  }
  AllBlogsModel newBlogsModelSpecific = AllBlogsModel(
      data: [],
      links: Links(first: '', last: '', prev: '', next: ''),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [
            Links(first: 'first', last: 'last', prev: 'prev', next: 'next')
          ],
          perPage: 0,
          to: 0, path: '', total: 0,
  ));

  AllBlogsModel allBlogsModelSpecific = AllBlogsModel(
      data: [],
      links: Links(first: '', last: '', prev: '', next: ''),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [
            Links(first: 'first', last: 'last', prev: 'prev', next: 'next')
          ],
          perPage: 0,
          to: 0, path: '', total: 0,
  ));


  int specificPage = 0;
  Future<void> getMoreSpecificArticles({required String path}) async {
    emit(GetMoreSpecificArticlesLoading());
    final result = await articlesRepo.getMoreArticles(path: path);
    result.fold((failure) {
      emit(GetMoreSpecificArticlesFailure(error: failure.errMessage));
    }, (response) {
      try {
        newBlogsModelSpecific = AllBlogsModel.fromJson(response.data);
        specificPage = newBlogsModelSpecific.meta.currentPage;
        if (newBlogsModelSpecific.data.isEmpty) {
          emit(NoArticlesState());
        } else {
          allBlogsModel.data.addAll(newBlogsModelSpecific.data);
          emit(GetMoreSpecificArticlesSuccess(message: 'تم تحميل المقالات بنجاح'));
        }
      } catch (e) {
        emit(GetMoreSpecificArticlesFailure(error: "حدث خطأ ما، حاول مجدداً"));
      }
    });
  }




  AllSectionsModel allSectionsModel = AllSectionsModel(
      data: [],
      links: Links(first: 'first', last: 'last', prev: 'prev', next: 'next'),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [],
          path: 'path',
          perPage: 0,
          to: 0,
          total: 0));

  Future<void> getSections() async {
    emit(GetSectionsLoading());
    final result = await articlesRepo.getSections(number: 1);
    result.fold((failure) {
      emit(GetSectionsFailure(error: failure.errMessage));
    }, (response) {
      try {
        allSectionsModel = AllSectionsModel.fromJson(response.data);
        emit(GetSectionsSuccess(message: 'تم تحميل الأبواب بنجاح'));
      } catch (e) {
        emit(GetSectionsFailure(error: "حدث خطأ ما"));
      }
    });
  }
}
