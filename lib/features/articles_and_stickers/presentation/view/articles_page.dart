import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/util/constant.dart';
import '../manger/articles_cubit.dart';
import 'article_details/articles_body.dart';
import 'articles_top_bar.dart';

class ArticlesAndStickersPage extends StatelessWidget {
  const ArticlesAndStickersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticlesCubit, ArticlesState>(
      buildWhen: (previous, current) => current is! GetSectionsFailure,
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: state is GetSectionsFailure || state is GetArticlesError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "تأكد من اتصالك بالانترنت",
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(kPrimaryColor)),
                            onPressed: () {
                              context.read<ArticlesCubit>().getSections();
                              context
                                  .read<ArticlesCubit>()
                                  .getArticles(number: 10);
                            },
                            child: Text(
                              "اعادة المحاولة",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ))
                      ],
                    ),
                  )
                : SingleChildScrollView(
              controller:
              context.read<ArticlesCubit>().scrollController,
              child: Column(
                      children: [
                        ArticlesTopBar(),
                        Padding(
                          padding: EdgeInsets.only(
                              right: 17.0.w, left: 17.0.w, top: 18.0.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'أحدث المقالات',
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const ArticlesBody()
                            ],
                          ),
                        ),
                      ],
                    ),
                ),
          ),
        );
      },
    );
  }
}


