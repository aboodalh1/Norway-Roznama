import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/stickers/manger/categories/categories_cubit.dart';

import '../../../../core/util/constant.dart';
import '../manger/stickers/stickers_cubit.dart';

class StickerDialog extends StatelessWidget {
  const StickerDialog(
      {super.key, required this.stickersCubit, required this.catIndex, required this.stickerIndex, required this.categoriesCubit});
  final CategoriesCubit categoriesCubit;
  final StickersCubit stickersCubit;
  final int catIndex;
  final int stickerIndex;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: null,
        title: Row(
          children: [
            Text(
              categoriesCubit.categoriesModel.data[catIndex].name,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                stickersCubit.shareNetworkImage(categoriesCubit
                    .categoriesModel
                    .data[catIndex]
                    .stickers[stickersCubit.pageController.page!.toInt()]
                    .url);
              },
              child: Container(
                height: 35.h,
                width: 35.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.r),
                  color: Colors.white,
                ),
                child: Center(
                    child: Icon(
                      Icons.share,
                      color: kPinkColor,
                      size: 20.sp,
                    )),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            InkWell(
              onTap: () {
                stickersCubit.saveNetworkImageLocally(
                    categoriesCubit
                        .categoriesModel
                        .data[catIndex]
                        .stickers[stickersCubit.pageController.page!.toInt()]
                        .url,
                    categoriesCubit
                        .categoriesModel
                        .data[catIndex]
                        .stickers[stickersCubit.pageController.page!.toInt()]
                        .name);
              },
              child: BlocProvider.value(
                value: stickersCubit,
                child: BlocBuilder<StickersCubit,StickersState>(
                  builder: (context, state) => Container(
                    height: 35.h,
                    width: 35.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                      color: Colors.white,
                    ),
                    child: Center(
                        child: state is StickerSaveLoading?Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: kPinkColor,
                          ),
                        ):Icon(
                          Icons.save_alt,
                          color: kPinkColor,
                          size: 20.sp,
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: 350.w,
          height: 400.h,
          child: PageView(
              controller: stickersCubit.pageController,
              children: List.generate(
                  categoriesCubit.categoriesModel.data[catIndex].stickers.length,
                      (index) {
                    return SizedBox(
                      width: 350.w,
                      height: 400.h,
                      child: FancyShimmerImage(
                          boxFit: BoxFit.contain,
                          imageUrl: categoriesCubit
                              .categoriesModel.data[catIndex].stickers[index]
                              .url),
                    );
                  })),
        ),
      ),
    );
  }
}