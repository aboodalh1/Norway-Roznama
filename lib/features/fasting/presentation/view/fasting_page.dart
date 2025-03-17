import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jhijri/_src/_jHijri.dart';

import '../../../../core/util/constant.dart';

class FastingPage extends StatefulWidget {
  const FastingPage({super.key});

  @override
  State<FastingPage> createState() => _FastingPageState();
}

class _FastingPageState extends State<FastingPage> {
  List<String> dayNam = [
    "الأيام البيض",
    "عاشوراء",
    "عرفة",
  ];
  List<String> details = [
    "13-14-15 من كل شهر",
    "العاشر من محرم",
    "التاسع من ذي الحجة",
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Color(0xffFFFFFF),
                  size: 23.sp,
                )),
            title: Text(
              "إعدادات الصيام",
              style: TextStyle(
                  color: Color(0xffFFFFFF),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                RamadanWidget(),
                SizedBox(
                  height: 35.h,
                ),
                FastingNotifyTile(),
                SizedBox(
                  height: 35.h,
                ),
                SizedBox(
                  child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 12.h,
                        );
                      },
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return FastingDayTile(
                          dayNam: dayNam,
                          details: details,
                          index: index,
                        );
                      }),
                )
              ],
            ),
          ),
        ));
  }
}

class FastingNotifyTile extends StatefulWidget {
  const FastingNotifyTile({
    super.key,
  });

  @override
  State<FastingNotifyTile> createState() => _FastingNotifyTileState();
}

class _FastingNotifyTileState extends State<FastingNotifyTile> {
  bool isExpand=false;
  bool isIftar = false;
  bool isSohor = false;
  bool isNotify=false;
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
                      isNotify=value;
                      if(isNotify){
                        isSohor=true;
                        isIftar=true;
                      }
                      else{
                        isIftar=false;
                        isSohor=false;
                      }
                    });
                  },
                ),
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      setState(() {
                        isExpand=!isExpand;
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0.w),
                    child: Row(
                      children: [
                        Text(
                          "الفطور",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        SizedBox(
                            height: 40.h,
                            child: Switch(
                              activeTrackColor: kPinkColor,
                              value: isIftar,
                              onChanged: (value) {
                                setState(() {
                                  isIftar=value;
                                  if(isIftar){
                                    isNotify=true;}
                                  if(isSohor==false&&isIftar==false){
                                    isNotify=false;
                                  }

                                });
                              },
                            ),)
                      ],
                    ),
                  ),
                  Divider(
                    height: 25.h,
                    thickness: 0.5.sp,
                    color: const Color(0xff889CB8),
                  ),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 20.0.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "السحور",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            SizedBox(
                                height: 40.h,
                                child:  Switch(
                                  activeTrackColor: kPinkColor,
                                  value: isSohor,
                                  onChanged: (value) {
                                    setState(() {
                                      isSohor=value;
                                      if(isSohor){
                                        isNotify=true;
                                      }
                                      if(isSohor==false&&isIftar==false){
                                        isNotify=false;
                                      }
                                    });
                                  },
                                ),)
                          ],
                        ),
                        SizedBox(height: 22.h,),
                        Row(
                          children: [
                            Text(
                              "وقت التنبيه",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                          Text("قبل ساعة",style: TextStyle(
                            fontSize: 12.sp,fontWeight: FontWeight.w500,color: Color(0xff7F7F7F)
                          ),),
                          Icon(Icons.arrow_forward_ios_rounded,size: 20.sp,color: Color(0xff7F7F7F),)
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

class FastingDayTile extends StatefulWidget {
  const FastingDayTile({
    super.key,
    required this.dayNam,
    required this.details,
    required this.index,
  });

  final List<String> dayNam;
  final List<String> details;
  final int index;

  @override
  State<FastingDayTile> createState() => _FastingDayTileState();
}

class _FastingDayTileState extends State<FastingDayTile> {
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffC0C0C0), width: 1),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Switch(
                        activeTrackColor: kPinkColor,
                        value: switchValue,
                        onChanged: (value) {
                          setState(() {
                            switchValue = !switchValue;
                          });
                        }),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        widget.dayNam[widget.index],
                        style: TextStyle(
                            color: const Color(0xff3D3D3D),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        widget.details[widget.index],
                        style: TextStyle(
                            color: const Color(0xff7F7F7F),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RamadanRemainingWidget extends StatelessWidget {
  const RamadanRemainingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 35.0.h, horizontal: 20.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Row(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "المتبقي لرمضان",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12.sp,
                      color: Color(0xff4D4D4D)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffD9D9D9),
                    borderRadius: BorderRadius.circular(13.r)),
                width: 106.w,
                height: 66.h,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "يوم",
                        style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Text(
                        "12",
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xffD4FBCE),
                        borderRadius: BorderRadius.circular(13.r)),
                    width: 106.w,
                    height: 66.h,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "شهر",
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            "01",
                            style: TextStyle(
                                fontSize: 20.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: -20.h,
                      left: -15.w,
                      child: Image.asset(
                        'assets/img/ramadan.png',
                        height: 35.h,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RamadanWidget extends StatelessWidget {
  const RamadanWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 35.0.h, horizontal: 20.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Row(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "أهلاً رمضان",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12.sp,
                      color: Color(0xff4D4D4D)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xffD4FBCE),
                        borderRadius: BorderRadius.circular(13.r)),
                    width: 205.w,
                    height: 66.h,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${JHijri.now().day}",
                            style: TextStyle(
                                fontSize: 24.sp, fontWeight: FontWeight.w500,color: kPrimaryColor),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Text(
                            JHijri.now().monthName,
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.w500,color: kPrimaryColor),
                          ),
                          SizedBox(width: 9.w,),
                          Container(decoration: BoxDecoration(shape: BoxShape.circle,color: Color(0xff535763)),width: 5.w,height: 5.h,),
                          SizedBox(width: 5.w,),
                          Text("${arabicDays[DateTime.now().weekday]}",style: TextStyle(fontSize: 12.sp,fontWeight: FontWeight.w500,color: Color(0xff545763)),)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: -20.h,
                      left: -15.w,
                      child: Image.asset(
                        'assets/img/ramadan.png',
                        height: 35.h,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
