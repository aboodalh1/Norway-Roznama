import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/util/constant.dart';
import '../../../../../core/util/functions.dart';
import '../../../../../core/widgets/custom_loading_indicator.dart';
import '../../manger/articles_cubit.dart';
import 'article_details_page.dart';

class SpecificDoorArticlesBody extends StatelessWidget {
  const SpecificDoorArticlesBody({
    super.key, required this.doorName,
  });
  final String doorName;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticlesCubit, ArticlesState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is GetArticlesLoading) {
          return Column(
            children: [
              SizedBox(height: 80.h),
              const CustomLoadingIndicator(),
            ],
          );
        }
        ArticlesCubit articlesCubit = context.read<ArticlesCubit>();
        return state is GetArticlesError || state is GetSectionsFailure
            ? Column(
          children: [
            SizedBox(height: 50.h),
            Text(
              state is GetArticlesError
                  ? state.error
                  : state is GetSectionsFailure? state.error:'',
              style: TextStyle(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () {
                articlesCubit.getArticles(number: 10);
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                ),
                backgroundColor: WidgetStateProperty.all(kPrimaryColor),
                shape: WidgetStateProperty.all(const LinearBorder()),
              ),
              child: Text(
                'أعد المحاولة',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            )
          ],
        )
            : state is NoArticlesState
            ? Text("لا يوجد مقالات في هذا الباب بعد")
            : state is GetSpecificArticlesSuccess ?Column(
          children: [
            SizedBox(
              width: 356.w,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r),
                    topLeft: Radius.circular(12.r),
                  ),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          navigateTo(context, ArticleDetailsPage(
                              doorName: doorName,
                              htmlFreeContent: articlesCubit.allBlogsModelSpecific
                                  .data[index].htmlFreeContent,
                              title: articlesCubit.allBlogsModelSpecific
                                  .data[index].title,
                              content: articlesCubit.allBlogsModelSpecific
                                  .data[index].content,
                              picture: articlesCubit.allBlogsModelSpecific
                                  .data[index].images.isNotEmpty ? articlesCubit.allBlogsModelSpecific
                                  .data[index].images[0].url : "null"));
                        },
                        child: Container(
                          padding:
                          EdgeInsets.symmetric(horizontal: 6.w),
                          height: 300.h,
                          decoration: BoxDecoration(
                            color: kGreyColor,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 30.h,
                                  child: Text(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    articlesCubit.allBlogsModelSpecific
                                        .data[index].title,
                                    style: TextStyle(
                                      decoration:
                                      TextDecoration.underline,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 370,
                                height: 60.h,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0.w),
                                    child:
                                    Container(
                                      constraints: BoxConstraints(
                                          maxHeight: 200.h),
                                      // Adjust height for 2 lines
                                      child: Html(
                                        data: articlesCubit.allBlogsModelSpecific
                                            .data[index].content,

                                      ),
                                    )
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Center(
                                child: articlesCubit.allBlogsModelSpecific
                                    .data[index].images.isEmpty ? Container(
                                  height: 143.h,
                                  width: 319.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("بدون صورة", style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.withOpacity(0.8)
                                      ),),
                                    ],
                                  ),
                                ) : FancyShimmerImage(
                                  errorWidget: Container(
                                    height: 143.h,
                                    width: 319.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Text("حدث خطأ في تحميل الصورة",
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey.withOpacity(
                                                  0.8)
                                          ),),
                                        IconButton(
                                            onPressed: () {

                                            },
                                            icon: Icon(
                                              Icons.refresh, size: 25.sp,
                                              color: Colors.grey,))
                                      ],
                                    ),
                                  ),
                                  imageUrl:
                                  articlesCubit.allBlogsModelSpecific
                                      .data[index].images[0].url,
                                  height: 143.h,
                                  width: 319.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                    const Divider(
                      height: 0.5,
                      color: Colors.grey,
                    ),
                    itemCount:
                    articlesCubit.allBlogsModelSpecific.data.length,
                  ),
                ),
              ),
            ),
            if(state is GetMoreArticlesLoading) Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: 30.w,
                  height: 35.h,
                  child: CircularProgressIndicator(color: kPrimaryColor,)),
            ), if(state is GetMoreArticlesFailure) Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: double.infinity,
                  height: 85.h,
                  child: Column(
                    children: [
                      Text("فشل تحميل المزيد...",
                        style: TextStyle(fontSize: 15.sp),),
                      IconButton(onPressed: () {
                        if (articlesCubit.specificPage == 1 &&
                            articlesCubit.allBlogsModelSpecific.links.next.isNotEmpty) {
                          articlesCubit.getMoreArticles(
                              path: articlesCubit.allBlogsModelSpecific.links.next);
                        }
                        else {
                          if (articlesCubit.newBlogsModelSpecific.links.next
                              .isNotEmpty) {
                            articlesCubit.getMoreArticles(
                                path: articlesCubit.newBlogsModelSpecific.links.next);
                          }
                        }
                      }, icon: Icon(Icons.refresh)),
                    ],
                  )),
            ),
            if(articlesCubit.newBlogsModelSpecific.links.next.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 190.w,
                    height: 35.h,
                    child: Center(child: Text(" انتهت المقالات المتوفرة",
                      style: TextStyle(
                          fontSize: 15.sp, color: Colors.black),))),
              )
          ],
        ):SizedBox();
      },
    );
  }
}