import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/util/assets_loader.dart';
import '../../../../../core/util/constant.dart';
import '../../manger/home_cubit.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.homeCubit,
  });

  final HomeCubit homeCubit;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        selectedLabelStyle: const TextStyle(color: Color(0xffFFFFFF)),
        unselectedLabelStyle:
        const TextStyle(color: Color(0xffFFFFFF)),
        selectedItemColor: Colors.white,
        backgroundColor: kPrimaryColor,
        currentIndex: context.read<HomeCubit>().currentIndex,
        onTap: (index) {
          context.read<HomeCubit>().changeNavBar(index);
        },
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(homeCubit.currentIndex == 0
                  ? AssetsLoader.selectedHome
                  : AssetsLoader.unselectedHome),
              label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Image.asset(homeCubit.currentIndex == 1
                  ? AssetsLoader.selectedArticles
                  : AssetsLoader.unselectedArticles),
              label: 'المقالات'),
          BottomNavigationBarItem(
              icon: Image.asset(
                homeCubit.currentIndex == 2
                    ? AssetsLoader.selectedSettings
                    : AssetsLoader.unselectedSettings,
                width: 30.w,
                height: 30.h,
              ),
              label: 'اعدادات'),
        ]);
  }
}