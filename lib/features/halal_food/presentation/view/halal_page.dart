import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/service_locator.dart';
import 'package:norway_roznama_new_project/features/halal_food/data/repos/halal_repo_impl.dart';

import '../../../../core/util/constant.dart';
import '../../../../core/util/functions.dart';
import '../manger/halal_cubit.dart';
import 'barcode_scanner_page.dart';


class HalalPage extends StatelessWidget {
  const HalalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocProvider(
  create: (context) => HalalCubit(getIt.get<HalalRepoImpl>()),
  child: BlocConsumer<HalalCubit, HalalState>(
  listener: (context, state) {},
  builder: (context, state) {
    HalalCubit halalCubit=context.read<HalalCubit>();
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back,size: 25.sp,color: Colors.white,)),
          backgroundColor: kPrimaryColor,
          title: Text('مأكولات حلال',style: TextStyle(fontSize: 14.sp,color: Colors.white),),
        ),
        body:  Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 78.0.h,),
                child: Image.asset('assets/img/halal_body.png',height: 180.h,width: 180.w,),
              ),
              SizedBox(height: 30.h),
              Text('قم بتصوير الباركود الخاص بالمنتج للتحقق من حليته',style: TextStyle(fontSize: 14.sp),),
              SizedBox(height: 20.h , ),
              ElevatedButton(
                onPressed: () {
                  navigateTo(context,BarcodeScannerPage(halalCubit: halalCubit,));
                },
                style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(
                            vertical: 8.h,horizontal: 12.w)),
                    backgroundColor:
                    WidgetStateProperty.all(
                        kPrimaryColor),
                    shape: WidgetStateProperty.all(
                        const LinearBorder())),
                child: Text(
                  'فتح الكاميرا',
                  style: TextStyle(color: Colors.white,fontSize: 14.sp),
                ),
              )
            ],
          ),
        ),
      );
  },
),
),
    );}
}
