import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/functions.dart';
import 'package:norway_roznama_new_project/features/advice/presentation/view/advice_page.dart';

import '../../../../core/widgets/custom_switch.dart';
import '../manger/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          SettingsCubit settingsCubit = context.read<SettingsCubit>();
          return Scaffold(
            appBar: AppBar(
              title: Text('إعدادات', style: TextStyle(
                  fontSize: 20.sp,
                color: Colors.white
              ),),
            ),
          body: Container(
            margin: EdgeInsets.symmetric(vertical: 50.h,horizontal: 20.w),
            child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context,index){
              return InkWell(
                onTap: (){
                  index==0?navigateTo(context, AdvicePage()):
                      index==2?settingsCubit.changeSwitchValue(!settingsCubit.switchValue):null;
                },
                child: Row(
                  children: [
                    Image.asset(settingsCubit.settingsTiles[index].icon,height: 30.h,width: 30.w,),
                    SizedBox(width: 20.w,),
                    Text(settingsCubit.settingsTiles[index].title,style: TextStyle(
                        fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),),
                    Spacer(),
                    settingsCubit.settingsTiles[index].isSwitch?CustomSwitch(
                      switchValue: settingsCubit.switchValue,
                      function: (value){
                        settingsCubit.changeSwitchValue(value);
                      },
                    ):SizedBox(),
                ]),
              );
            }, separatorBuilder: (context,index){return SizedBox(height: 30.h);},
                itemCount: 3),
          )
          );
        },
      ),
    );
  }
}


