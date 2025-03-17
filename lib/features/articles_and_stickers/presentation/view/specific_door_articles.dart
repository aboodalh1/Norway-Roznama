import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/util/constant.dart';
import '../../../home/presentation/manger/home_cubit.dart';
import '../manger/articles_cubit.dart';
import 'article_details/specific_door_articles_body.dart';

class SpecificDoorArticles extends StatefulWidget {
  const SpecificDoorArticles({super.key, required this.homeCubit,required this.doorName, required this.sectionId});
  final HomeCubit homeCubit;
  final String doorName;
  final int sectionId;
  @override
  State<SpecificDoorArticles> createState() => _SpecificDoorArticlesState();
}

class _SpecificDoorArticlesState extends State<SpecificDoorArticles> {
  @override
  @override
  void initState() {
    super.initState();
    context.read<ArticlesCubit>().getArticles(number: 10,sectionId: widget.sectionId);
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider.value(
        value: widget.homeCubit,
        child: BlocBuilder<ArticlesCubit, ArticlesState>(
          builder: (context, state) {
            return Scaffold(
              body: state is GetArticlesError
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
                            WidgetStateProperty.all(kPrimaryColor)),
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
                    child: Column(
                      children: [
                    AppBar(
                      elevation: 5,
                      toolbarHeight: 75.h,
                      leading: IconButton(onPressed: (){Navigator.of(context).pop();},
                          icon: Icon(Icons.arrow_back,size: 20.sp,color: Colors.white,)),
                      title: SizedBox(
                        height: 40.h,
                        width: 250.w,
                        child: BlocConsumer<HomeCubit, HomeState>(
                            listener: (context, state) {},
                            builder: (context, state) {
                              HomeCubit homeCubit = context.read<HomeCubit>();
                              return SizedBox(
                                width: 250.w,
                                child: TextFormField(
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      context
                                          .read<ArticlesCubit>()
                                          .getArticles(
                                          number: 5,
                                          sectionId: widget.sectionId,
                                          );
                                    }
                                    if (value.isNotEmpty) {
                                      context
                                          .read<ArticlesCubit>()
                                          .getArticles(
                                          number: 5,
                                          sectionId: widget.sectionId,
                                        title: value.trim()
                                          );
                                    }
                                  },
                                  textInputAction: TextInputAction.search,
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
                                    hintText: 'بحث في ${widget.doorName}',
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: 17.0.w, left: 17.0.w, top: 18.0.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.doorName,
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SpecificDoorArticlesBody(doorName: widget.doorName,)
                        ],
                      ),
                    ),
                                    ],
                                  ),
                  ),
            );
          },
        ),
      ),
    );
  }
}
