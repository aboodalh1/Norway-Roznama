
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
            height: isExpand ? 200.h : 0,
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
                        Row(
                          children: [
                            Text(
                              "وقت التنبيه",
                              style: TextStyle(
                                  fontSize: 12.sp, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            Text(
                              "قبل ساعة",
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
