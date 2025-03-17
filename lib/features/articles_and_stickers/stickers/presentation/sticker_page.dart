import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/core/util/service_locator.dart';
import 'package:norway_roznama_new_project/core/widgets/custom_snack_bar.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/data/repos/stickers_repos/stickers_repo_impl.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/stickers/manger/categories/categories_cubit.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/stickers/presentation/sticker_dialog.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/stickers/presentation/stickers_error_body.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/stickers/presentation/stickers_loading_body.dart';

import '../manger/stickers/stickers_cubit.dart';

class StickersPage extends StatelessWidget {
  const StickersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CategoriesCubit(getIt.get<StickersRepoImpl>()),
        ),
        BlocProvider(
          create: (context) => StickersCubit(getIt.get<StickersRepoImpl>()),
        ),
      ],
      child: BlocConsumer<StickersCubit, StickersState>(
        listener: (context, state) {
          if (state is StickerSavedSuccess) {
            customSnackBar(context, state.message, color: kPrimaryColor);
            Navigator.of(context).pop();
          }
          if (state is StickerSavedFailure) {
            customSnackBar(context, "حدث خطأ اثناء حفظ الصورة",
                color: Colors.red);
          }
        },
        builder: (context, state) {
          StickersCubit stickersCubit = context.read<StickersCubit>();
          return BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, state1) {
              CategoriesCubit categoriesCubit = context.read<CategoriesCubit>();
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  appBar: AppBar(
                    leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 25.sp,
                        )),
                    title: Text(
                      "المصلقات",
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  body: state1 is CategoriesLoadingState
                      ? StickerLoadingBody()
                      : state1 is CategoriesErrorState
                      ? StickersErrorBody(error: state1.error)
                      : Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 29, horizontal: 15.0),
                    child: SingleChildScrollView(
                      controller: stickersCubit.scrollController,
                      child: Column(
                        children: [
                          SizedBox(
                            child: ListView.separated(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (context, catIndex) {
                                return Divider(
                                  thickness: 0.7,
                                  height: 40.h,
                                  color: Color(0xffAEAEAE),
                                );
                              },
                              itemCount: categoriesCubit
                                  .categoriesModel.data.length,
                              itemBuilder: (context, catIndex) =>
                                  Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(categoriesCubit.categoriesModel
                                                .data[catIndex].name),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Stack(
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 83.h,
                                                  child: ListView.separated(
                                                      scrollDirection:
                                                      Axis.horizontal,
                                                      shrinkWrap: true,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return StickerCard(
                                                          categoriesCubit: categoriesCubit,
                                                          index: index,
                                                          stickersCubit:
                                                          stickersCubit,
                                                          catIndex: catIndex,
                                                        );
                                                      },
                                                      separatorBuilder:
                                                          (context, index) {
                                                        return SizedBox(
                                                          width: 7.85.w,
                                                        );
                                                      },
                                                      itemCount: categoriesCubit
                                                          .categoriesModel
                                                          .data[catIndex]
                                                          .stickers
                                                          .length),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ]),
                            ),
                          ),
                          if (state1 is MoreCategoriesLoadingState)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  width: 30.w,
                                  height: 35.h,
                                  child: CircularProgressIndicator(
                                    color: kPrimaryColor,
                                  )),
                            ),
                          if (state1 is MoreCategoriesErrorState)
                            MoreCategoriesErrorWidget(
                              categoriesCubit: categoriesCubit,
                                error: state1.error,
                                stickersCubit: stickersCubit),
                          if (categoriesCubit
                              .newCategoriesModel.links.next.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  width: 190.w,
                                  height: 35.h,
                                  child: Center(
                                      child: Text(
                                        " انتهت الملصقات المتوفرة",
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.black),
                                      ))),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StickerCard extends StatelessWidget {
  const StickerCard({
    super.key,
    required this.stickersCubit,
    required this.catIndex,
    required this.index, required this.categoriesCubit,
  });
  final CategoriesCubit categoriesCubit;
  final StickersCubit stickersCubit;
  final int catIndex;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        stickersCubit.pageController = PageController(initialPage: index);
        if (categoriesCubit
            .categoriesModel.data[catIndex].stickers[index].isSelected) {
          stickersCubit.changeSelected(false);
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return StickerDialog(
                    stickerIndex: index,
                    catIndex: catIndex,
                    stickersCubit: stickersCubit, categoriesCubit: categoriesCubit,);
              });
        }
      },
      onLongPress: () {
        // for(int i=0;i<stickersCubit.categoriesModel.data[catIndex].stickers.length;i++){
        //   stickersCubit.changeSelected(false);
        // }
        //   stickersCubit.categoriesModel.data[catIndex].stickers[index].isSelected = !stickersCubit.categoriesModel.data[catIndex].stickers[index].isSelected;
        // for(int i=0;i<stickersCubit.categoriesModel.data[catIndex].stickers.length;i++) {
        // }
      },
      child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topLeft,
          children: [
            SizedBox(
              height: 88.h,
              width: 83.w,
              child: FancyShimmerImage(
                  imageUrl: categoriesCubit
                      .categoriesModel.data[catIndex].stickers[index].url),
            ),
            if (categoriesCubit
                .categoriesModel.data[catIndex].stickers[index].isSelected)
              Positioned(
                top: -10.h,
                child: InkWell(
                  onTap: () {
                    stickersCubit.shareNetworkImage(categoriesCubit
                        .categoriesModel.data[catIndex].stickers[index].url);
                  },
                  child: Container(
                    height: 30.h,
                    width: 30.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                      color: Colors.white,
                    ),
                    child: Center(
                        child: Icon(
                          Icons.share,
                          color: kPinkColor,
                          size: 15.sp,
                        )),
                  ),
                ),
              ),
            if (categoriesCubit
                .categoriesModel.data[catIndex].stickers[index].isSelected)
              Positioned(
                top: 25.h,
                left: -10.w,
                child: InkWell(
                  onTap: () {
                    stickersCubit.saveNetworkImageLocally(
                        categoriesCubit
                            .categoriesModel.data[catIndex].stickers[index].url,
                        categoriesCubit.categoriesModel.data[catIndex]
                            .stickers[index].name);
                  },
                  child: Container(
                    height: 30.h,
                    width: 30.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                      color: Colors.white,
                    ),
                    child: BlocBuilder<StickersCubit, StickersState>(
                      builder: (context, state) =>
                          Center(
                              child: state is StickerSaveLoading
                                  ? CircularProgressIndicator(
                                color: kPinkColor,
                              )
                                  : Icon(
                                Icons.save_alt_outlined,
                                color: kPinkColor,
                                size: 15.sp,
                              )),
                    ),
                  ),
                ),
              )
          ]),
    );
  }
}

class MoreCategoriesErrorWidget extends StatelessWidget {
  const MoreCategoriesErrorWidget({
    super.key,
    required this.stickersCubit,
    required this.error, required this.categoriesCubit,
  });
  final CategoriesCubit categoriesCubit;
  final StickersCubit stickersCubit;
  final String error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            error,
            style: TextStyle(fontSize: 15.sp),
          ),
          IconButton(
              onPressed: () {
                if (stickersCubit.page == 1 &&
                    categoriesCubit.categoriesModel.links.next.isNotEmpty) {
                  categoriesCubit.getMoreCategories(
                      path: categoriesCubit.categoriesModel.links.next);
                } else {
                  if (categoriesCubit.newCategoriesModel.links.next.isNotEmpty) {
                    categoriesCubit.getMoreCategories(
                        path: categoriesCubit.newCategoriesModel.links.next);
                  }
                }
              },
              icon: Icon(Icons.refresh)),
        ],
      ),
    );
  }
}
