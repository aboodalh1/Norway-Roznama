import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/data/model/stickers/stickers_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/model/blogs_model.dart';
import '../../../data/repos/stickers_repos/stickers_repo.dart';
part 'stickers_state.dart';


class StickersCubit extends Cubit<StickersState> {
  StickersCubit(this.stickersRepo)
      : scrollController = ScrollController(),
        super(StickersInitial()) {
    getStickers(catId: 2);
    scrollController.addListener(_onScrollStickers);
    // stickersScrollController.addListener(_onScrollStickers);
  }

  PageController pageController = PageController();

  bool isSelected = false;
  void changeSelected(bool value) {
    isSelected = value;
    emit(SelectSticker());
  }

  num page = 0;
  final ScrollController scrollController;
  StickersRepo stickersRepo;

  ScrollController stickersScrollController = ScrollController();

  void _onScrollStickers() {
    // if (stickersScrollController.position.pixels ==
    //     stickersScrollController.position.maxScrollExtent) {
    //   if (page == 1 && categoriesModel.links.next.isNotEmpty) {
    //     getMoreStickers(path: categoriesModel.links.next);
    //   } else {
    //     if (newStickersModel.links.next.isNotEmpty) {
    //       getMoreStickers(path: newStickersModel.links.next);
    //     }
    //   }
    //   if (stickersScrollController.position.atEdge) {
    //     if (stickersScrollController.position.pixels == 0) {
    //       emit(StickersLoaded(false)); // At the top
    //     } else {
    //       emit(StickersLoaded(true)); // At the bottom
    //     }
    //   }
    // else {
    //     emit(StickersLoaded(false)); // More items to scroll
    //   }
    // }
  }

  @override
  Future<void> close() {
    scrollController.removeListener(_onScrollStickers);
    scrollController.dispose();
    return super.close();
  }

  final String assetImagePath = 'assets/images/example.png';

  Future<void> shareNetworkImage(String imageUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.png');

      final dio = Dio();
      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.data);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: '',
        );
      } else {
        debugPrint(
            'Error: Failed to download image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sharing network image: $e');
    }
  }

  Future<String> saveNetworkImageLocally(String imageUrl, String fileName) async {
    emit(StickerSaveLoading());
    try {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        emit(StickerSavedFailure(error: "لم يتم اختيار مجلد لحفظ الملصق"));
        return '';
      }

      final sanitizedFileName =
      fileName.endsWith(".png") ? fileName : "$fileName.png";
      final filePath = '$selectedDirectory/$sanitizedFileName';

      final dio = Dio();
      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.data);

        emit(StickerSavedSuccess(message: "تم حفظ الملصق بنجاح"));
        return filePath;
      } else {
        emit(StickerSavedFailure(error: "حدث خطأ أثناء تحميل الصورة"));
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      emit(StickerSavedFailure(error: "حدث خطأ أثناء حفظ الملصق"));
      throw Exception('Error saving network image: $e');
    }
  }


  Future<void> getStickers({required catId}) async {
    emit(StickersLoadingState());
    var result = await stickersRepo.getStickers(catId: catId, perPage: 5);
    result.fold((failure) {
      emit(StickerErrorState(error: failure.errMessage));
    }, (response) {
      stickersModel = StickersModel.fromJson(response.data);
      emit(StickerSuccessState());
    });
  }

  StickersModel stickersModel = StickersModel(
      data: [],
      links: Links(first: '', last: '', prev: '', next: ''),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [],
          path: '',
          perPage: 0,
          to: 0,
          total: 0));

  StickersModel newStickersModel = StickersModel(
      data: [],
      links: Links(first: 'first', last: 'last', prev: 'prev', next: 'next'),
      meta: Meta(
          currentPage: 0,
          from: 0,
          lastPage: 0,
          links: [],
          path: '',
          perPage: 0,
          to: 0,
          total: 0));

  // Future<void> getMoreStickers({required String path}) async {
  //   emit(MoreStickersLoadingState());
  //   final result = await stickersRepo.getMoreStickers(path: path);
  //   result.fold((failure) {
  //     emit(MoreStickerErrorState(error: failure.errMessage));
  //   }, (response) {
  //     try {
  //       newStickersModel = StickersModel.fromJson(response.data);
  //       page = newStickersModel.meta.currentPage;
  //       if (newStickersModel.data.isEmpty) {
  //         emit(EndCategoriesState());
  //       } else {
  //         newStickersModel.data.addAll(newStickersModel.data);
  //         emit(MoreStickerSuccessState());
  //       }
  //     } catch (e) {
  //       emit(MoreStickerErrorState(error: "حدث خطأ ما، حاول مجدداً"));
  //     }
  //   });
  // }
}
