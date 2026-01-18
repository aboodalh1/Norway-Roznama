import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/data/model/stickers/stickers_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/repos/stickers_repos/stickers_repo.dart';
part 'stickers_state.dart';

class StickersCubit extends Cubit<StickersState> {
  StickersCubit(this.stickersRepo)
      : scrollController = ScrollController(),
        super(StickersInitial()) {
    scrollController.addListener(_onScrollStickers);
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
    if (stickersScrollController.position.pixels ==
        stickersScrollController.position.maxScrollExtent) {
      if (page == 1 && stickersModel.links1!.next!.isNotEmpty) {
        getMoreStickers(path: stickersModel.links1!.next!);
      } else {
        if (newStickersModel.links1!.next!.isNotEmpty) {
          getMoreStickers(path: newStickersModel.links1!.next!);
        }
      }
      if (stickersScrollController.position.atEdge) {
        if (stickersScrollController.position.pixels == 0) {
          emit(StickersLoaded(false)); // At the top
        } else {
          emit(StickersLoaded(true)); // At the bottom
        }
      } else {
        emit(StickersLoaded(false)); // More items to scroll
      }
    }
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

  Future<String> saveNetworkImageLocally(
      String imageUrl, String fileName) async {
    emit(StickerSaveLoading());
    try {
      // Download image bytes
      final dio = Dio();
      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode != 200) {
        emit(StickerSavedFailure(error: "حدث خطأ أثناء تحميل الصورة"));
        throw Exception("Error: ${response.statusCode}");
      }

      // Save image directly to gallery using image_gallery_saver_plus
      // This uses MediaStore API and works with Scoped Storage
      final sanitizedFileName =
          fileName.endsWith(".png") ? fileName : "$fileName.png";

      final Uint8List imageBytes = Uint8List.fromList(response.data);

      // Save to gallery - this will make it visible in gallery apps
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        name: sanitizedFileName.replaceAll('.png', ''),
        quality: 100,
      );

      // Extract path from result
      final savedPath =
          result['filePath'] as String? ?? result['path'] as String? ?? '';

      if (result['isSuccess'] == true && savedPath.isNotEmpty) {
        emit(StickerSavedSuccess(message: "تم حفظ الملصق في معرض الصور بنجاح"));
        return savedPath;
      } else {
        emit(StickerSavedFailure(error: "حدث خطأ أثناء حفظ الملصق"));
        throw Exception('Failed to save image to gallery');
      }
    } catch (e) {
      emit(StickerSavedFailure(
          error: "حدث خطأ أثناء حفظ الملصق: ${e.toString()}"));
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
  );
  StickersModel newStickersModel = StickersModel(
    data: [],
  );

  Future<void> getMoreStickers({required String path}) async {
    emit(MoreStickersLoadingState());
    final result = await stickersRepo.getMoreStickers(path: path);
    result.fold((failure) {
      emit(MoreStickerErrorState(error: failure.errMessage));
    }, (response) {
      try {
        newStickersModel = StickersModel.fromJson(response.data);
        page = newStickersModel.meta!.currentPage!;
        if (newStickersModel.data!.isEmpty) {
          emit(EndStickersState());
        } else {
          newStickersModel.data!.addAll(newStickersModel.data!);
          emit(MoreStickerSuccessState());
        }
      } catch (e) {
        emit(MoreStickerErrorState(error: "حدث خطأ ما، حاول مجدداً"));
      }
    });
  }
}
