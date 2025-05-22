
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';


class FastingNotifyTile extends StatefulWidget {
  const FastingNotifyTile({
    super.key,
  });

  @override
  State<FastingNotifyTile> createState() => _FastingNotifyTileState();
}

class _FastingNotifyTileState extends State<FastingNotifyTile> {
  bool isExpand = false;
  double confirmbeforeSuhur = CacheHelper.getData(key: 'before_suhur') ??15;
  double beforeSuhur = CacheHelper.getData(key: 'before_suhur') ??15;
  bool isIftar = CacheHelper.getData(key: 'is_iftar') ??false;
  bool isSohor = CacheHelper.getData(key: 'is_sohor') ??false;
  bool isNotify = CacheHelper.getData(key: 'is_notify') ??false;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ListTile(
                tileColor: null,
                subtitle: Text(
                  "فطور وسحور",
                  style: TextStyle(
                      color: const Color(0xff7F7F7F),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500),
                ),
                title: Text(
                  'تنبيهات رمضان',
                  style: TextStyle(
                      color: const Color(0xff3D3D3D),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500),
                ),
                trailing: Switch(
                  activeTrackColor: kPinkColor,
                  value: isNotify,
                  onChanged: (value) {
                    setState(() {
                      isNotify = value;
                      if (isNotify) {
                        isSohor = true;
                        isIftar = true;
                      } else {
                        isIftar = false;
                        isSohor = false;
                      }
                    });
                    CacheHelper.saveData(key: 'is_notify', value: isNotify);
                    CacheHelper.saveData(key: 'is_iftar', value: isIftar);
                    CacheHelper.saveData(key: 'is_sohor', value: isSohor);
                  },
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      setState(() {
                        isExpand = !isExpand;
                      });
                    });
                  },
                  icon: Icon(isExpand
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down))
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: isExpand ? 210.h : 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              color: const Color(0xffEEEEEE),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                    child: Row(
                      children: [
                        Text(
                          "الفطور",
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 40.h,
                          child: Switch(
                            activeTrackColor: kPinkColor,
                            value: isIftar,
                            onChanged: (value) {
                              setState(() {
                                isIftar = value;
                                if (isIftar) {
                                  isNotify = true;
                                }
                                if (isSohor == false && isIftar == false) {
                                  isNotify = false;
                                }
                              });
                              CacheHelper.saveData(key: 'is_iftar', value: isIftar);
                              CacheHelper.saveData(key: 'is_notify', value: isNotify);
                              },
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 25.h,
                    thickness: 0.5.sp,
                    color: const Color(0xff889CB8),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "السحور",
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 40.h,
                              child: Switch(
                                activeTrackColor: kPinkColor,
                                value: isSohor,
                                onChanged: (value) {
                                  setState(() {
                                    isSohor = value;
                                    if (isSohor) {
                                      isNotify = true;
                                    }
                                    if (isSohor == false && isIftar == false) {
                                      isNotify = false;
                                    }
                                  });
                                  CacheHelper.saveData(key: 'is_sohor', value: isSohor);
                                  CacheHelper.saveData(key: 'is_notify', value: isNotify);
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 22.h,
                        ),
                        GestureDetector(
                          onTap: (){
                            showDialog(context: context, builder: (context){
                              return StatefulBuilder(
                                builder: (context, setStates) => AlertDialog(
                                  content: SizedBox(
                                    width: 231.w,
                                    height: 280.h,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "منبه السحور",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          "..قبل الاذان ب",
                                          style: TextStyle(
                                              color: const Color(0xff535763),
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          height: 40.h,
                                        ),
                                        Slider(
                                            autofocus: true,
                                            divisions: 5,
                                            max: 80,
                                            min: 15,
                                            thumbColor: kGreyColor,
                                            activeColor: const Color(0xff3E73BC),
                                            value: beforeSuhur,
                                            onChanged: (value) {
                                              setStates(() {
                                               beforeSuhur = value;
                                              });
                                            }),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 28.w),
                                          child: Row(
                                            children: [
                                              Text(
                                                "15",
                                                style: TextStyle(
                                                    fontSize: 10.sp, fontWeight: FontWeight.w500),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "20",
                                                style: TextStyle(
                                                    fontSize: 10.sp, fontWeight: FontWeight.w500),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "30",
                                                style: TextStyle(
                                                    fontSize: 10.sp, fontWeight: FontWeight.w500),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "40",
                                                style: TextStyle(
                                                    fontSize: 10.sp, fontWeight: FontWeight.w500),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "60",
                                                style: TextStyle(
                                                    fontSize: 10.sp, fontWeight: FontWeight.w500),
                                              ),
                                              const Spacer(),
                                              Text(
                                                "80",
                                                style: TextStyle(
                                                    fontSize: 10.sp, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 28.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 28.0.w),
                                          child: Row(
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    "إالغاء",
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color(0xff3E73BC),
                                                    ),
                                                  )),
                                              const Spacer(),
                                              Container(
                                                height: 31.h,
                                                width: 1.w,
                                                color: const Color(0xff7F7F7F),
                                              ),
                                              const Spacer(),
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {

                                                    confirmbeforeSuhur = beforeSuhur;
                                                    });
                                                    CacheHelper.saveData(key: 'before_suhur', value: confirmbeforeSuhur);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    "موافق",
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color(0xff3E73BC),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  backgroundColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  elevation: 0,
                                  surfaceTintColor: Colors.white,
                                ),
                              );
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                "وقت التنبيه",
                                style: TextStyle(
                                    fontSize: 12.sp, fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Text(
                                "قبل ب ${confirmbeforeSuhur.toInt()} دقيقة",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff7F7F7F)),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 20.sp,
                                color: Color(0xff7F7F7F),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
