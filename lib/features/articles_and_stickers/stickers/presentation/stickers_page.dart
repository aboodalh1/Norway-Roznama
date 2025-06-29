import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/core/util/service_locator.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/data/repos/stickers_repos/stickers_repo_impl.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/stickers/manger/stickers/stickers_cubit.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/stickers/presentation/stickers_error_body.dart';

import '../../../../core/widgets/custom_snack_bar.dart';

class StickersPage extends StatelessWidget {
  const StickersPage(
      {super.key, required this.catIndex, required this.catName});

  final int catIndex;

  final String catName;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
        create: (context) => StickersCubit(getIt.get<StickersRepoImpl>())
          ..getStickers(catId: catIndex),
        child: BlocConsumer<StickersCubit, StickersState>(
          listener: (context, state) {
            if (state is StickerSavedSuccess) {
              customSnackBar(context, state.message, color: kPrimaryColor);
            }
            if (state is StickerSavedFailure) {
              customSnackBar(context, "حدث خطأ اثناء حفظ الصورة",
                  color: Colors.red);
            }
            if (state is StickerSaveLoading) {
              customSnackBar(context, "جاري حفظ الصورة", color: kPrimaryColor);
            }
          },
          builder: (context, state) {
            StickersCubit stickersCubit = context.read<StickersCubit>();
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22.sp,
                    )),
                title: Text(
                  catName,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ),
              body: state is StickersLoadingState
                  ? Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    )
                  : state is StickerErrorState
                      ? StickersErrorBody(
                          error: state.error,
                        )
                      : GridView.builder(
                          itemBuilder: (context, index) {
                            return InkWell(
                              onLongPress: () {
                                stickersCubit.saveNetworkImageLocally(
                                  stickersCubit.stickersModel.data![index].url!,
                                  stickersCubit.stickersModel.data![index].id
                                      .toString(),
                                );
                              },
                              child: FancyShimmerImage(
                                  boxFit: BoxFit.contain,
                                  imageUrl:
                                  stickersCubit
                                      .stickersModel.data![index].url!),
                            );
                          },
                         controller: stickersCubit.scrollController,
                          itemCount: stickersCubit.stickersModel.data!.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10.h,
                            crossAxisSpacing: 10.w,
                            childAspectRatio: 1,
                          )),
            );
          },
        ),
      ),
    );
  }
}
