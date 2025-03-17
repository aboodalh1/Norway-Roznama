import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/features/articles_and_stickers/presentation/view/specific_door_articles.dart';

import '../../../../core/util/constant.dart';
import '../../../../core/util/functions.dart';
import '../../../home/presentation/manger/home_cubit.dart';
import '../manger/articles_cubit.dart';

class ArticlesTopBar extends StatelessWidget {
  const ArticlesTopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 5,
      toolbarHeight: 75.h,
      leading: SizedBox(),
      title: SizedBox(
        height: 40.h,
        width: 250.w,
        child: BlocConsumer<HomeCubit, HomeState>(
            listener: (context, state) {},
            builder: (context, state) {
              HomeCubit homeCubit = context.read<HomeCubit>();
              return TextFormField(
                key: homeCubit.searchBarKey,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    context
                        .read<ArticlesCubit>()
                        .getArticles(
                        number: 5,
                        sectionId: homeCubit
                            .selectedSectionId,
                        title: value.trim());
                  }
                },
                textInputAction: TextInputAction.search,
                readOnly: !homeCubit.isSectionSelected,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400),
                controller: homeCubit.searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide.none),
                  fillColor: kGreyColor,
                  filled: true,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 22.sp,
                  ),
                  hintText: 'مقالات عن',
                ),
                onTap: () {
                  if (!homeCubit.searchController.text.isNotEmpty) {
                    RenderBox renderBox =
                    homeCubit.searchBarKey
                        .currentContext!
                        .findRenderObject()
                    as RenderBox;
                    Offset position = renderBox
                        .localToGlobal(Offset.zero);
                    showMenu(
                        context: context,
                        items: state
                        is GetSectionsLoading
                            ? [
                          PopupMenuItem(
                              child:
                              CircularProgressIndicator(
                                color: kPrimaryColor,
                              ))
                        ]
                            : context
                            .read<
                            ArticlesCubit>()
                            .allSectionsModel
                            .data
                            .isEmpty
                            ? [
                          PopupMenuItem(
                              child: Text(
                                  "لا يوجد ابواب"))
                        ]
                            : List.generate(
                            context
                                .read<
                                ArticlesCubit>()
                                .allSectionsModel
                                .data
                                .length,
                                (index) =>
                                PopupMenuItem(
                                    onTap: () {
                                      homeCubit.selectedSectionId = context
                                          .read<
                                          ArticlesCubit>()
                                          .allSectionsModel
                                          .data[
                                      index]
                                          .id;
                                      homeCubit.selectedSection = context
                                          .read<
                                          ArticlesCubit>()
                                          .allSectionsModel
                                          .data[
                                      index]
                                          .name;
                                      homeCubit
                                          .changeSearchEnabled(
                                          true);
                                      navigateTo(context,SpecificDoorArticles(
                                        sectionId:context
                                            .read<
                                            ArticlesCubit>()
                                            .allSectionsModel
                                            .data[
                                        index]
                                            .id,
                                        homeCubit: homeCubit,
                                      doorName: context
                                          .read<
                                          ArticlesCubit>()
                                          .allSectionsModel
                                          .data[
                                      index]
                                          .name,
                                      ));
                                    },
                                    child: Text(context
                                        .read<
                                        ArticlesCubit>()
                                        .allSectionsModel
                                        .data[
                                    index]
                                        .name))),
                        position: RelativeRect.fromLTRB(
                          position.dx,
                          position.dy +
                              renderBox.size.height,
                          position.dx +
                              renderBox.size.width,
                          position.dy,
                        ));
                  }
                },
              );
            }),
      ),
    );
  }
}