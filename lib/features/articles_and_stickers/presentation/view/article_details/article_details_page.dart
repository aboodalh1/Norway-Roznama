import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/util/constant.dart';

class ArticleDetailsPage extends StatelessWidget {
  const ArticleDetailsPage(
      {super.key, required this.title, required this.content, required this.picture, required this.htmlFreeContent, required this.doorName});

  final String title;
  final String content;
  final String picture;
  final String htmlFreeContent;
  final String doorName;
  void _shareArticle(BuildContext context) {
    final String textToShare = "$title\n\n$htmlFreeContent \n \n \n (بواسطة تطبيق االمجمع الاسلامي في النروج)"; // Combine title & content
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if(picture != "null") IconButton(onPressed: () {
              _shareArticle(context);
            }, icon: Icon(Icons.share, color: Colors.white, size: 25.sp,)),
          ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 25.sp,),
            onPressed: () {
              Navigator.of(context).pop();
            },),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.normal,
              fontSize: 14.sp,
              color: Colors.white),),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 18.0,right: 18.w),
                child: Row(
                  children: [
                    Text(
                      doorName,
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 17.w, vertical: 20.h),
                padding:
                EdgeInsets.symmetric(horizontal: 6.w, vertical: 15.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: kGreyColor,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      picture == "null" ? GestureDetector(
                        onTap: () {
                          _shareArticle(context);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          height: 43.h,
                          width: 47.w,
                          decoration: BoxDecoration(
                              border: Border.all(color: kPinkColor),
                              borderRadius: BorderRadius.circular(10.r)
                          ),
                          child: Icon(Icons.share, color: kPinkColor, size: 25.sp,),
                        ),
                      ) : FancyShimmerImage(
                        imageUrl: picture,
                        height: 143.h,
                        width: 319.w,
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          textAlign: TextAlign.start,
                          title,
                          style: TextStyle(
                            decoration:
                            TextDecoration.underline,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                          child: Html(data: content)
                      ),
          
          
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
