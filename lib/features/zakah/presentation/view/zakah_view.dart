import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/cacheHelper.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';
import 'package:norway_roznama_new_project/core/widgets/custom_switch.dart';
import 'package:norway_roznama_new_project/features/zakah/presentation/manger/zakah_cubit.dart';
import 'package:norway_roznama_new_project/notification_service.dart';

class ZakahView extends StatelessWidget {
  const ZakahView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ZakahCubit(),
      child: BlocBuilder<ZakahCubit, ZakahState>(
        builder: (context, state) {
          ZakahCubit zakahCubit = context.read<ZakahCubit>();
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
                        size: 20.sp,
                        color: Colors.white,
                      )),
                  title: Text(
                    "حاسبة الزكاة",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: Colors.white),
                  ),
                ),
                body: Padding(
                  padding: EdgeInsets.only(
                    top: 54.h,
                    left: 30.w,
                    right: 30.w,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "نوع المال",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              color: kBlackGrey),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(color: Color(0xffC0C0C0))),
                              width: 150.w,
                              height: 38.h,
                              child: DropdownButton(
                                  borderRadius: BorderRadius.circular(15.r),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    size: 20.sp,
                                  ),
                                  items: [
                                    ...zakahCubit.livestock.map((animal) {
                                      return DropdownMenuItem(
                                        value: animal['name'],
                                        child: Row(
                                          children: [
                                            Image.asset(animal['icon']),
                                            // Custom icon
                                            SizedBox(width: 8),
                                            Text(animal['name'],
                                                style: TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      );
                                    })
                                  ],
                                  onChanged: (value) {}),
                            ),
                            SizedBox(
                              width: 30.w,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(color: Color(0xffC0C0C0))),
                              width: 150.w,
                              height: 40.h,
                              child: DropdownButton(
                                  alignment: Alignment.centerLeft,
                                  borderRadius: BorderRadius.circular(15),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    size: 20.sp,
                                  ),
                                  items: [
                                    ...zakahCubit.livestock.map((animal) {
                                      return DropdownMenuItem(
                                        alignment: Alignment.center,
                                        value: animal['name'],
                                        child: Row(
                                          children: [
                                            Image.asset(animal['icon']),
                                            // Custom icon
                                            SizedBox(width: 8),
                                            Text(animal['name'],
                                                style: TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      );
                                    })
                                  ],
                                  onChanged: (value) {}),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 111.h,
                        ),
                        Text(
                          "مقدار المال",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              color: kBlackGrey),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                    width: 1.43, color: Color(0xffC0C0C0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                    width: 1.43, color: Color(0xffC0C0C0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide(
                                    width: 1.43, color: Color(0xffC0C0C0)),
                              )),
                        ),
                        SizedBox(
                          height: 45.h,
                        ),
                        NotificationRow(zakahCubit: zakahCubit),
                        SizedBox(
                          height: 45.h,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 10.w),
                          width: 334.w,
                          height: 124.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(color: Color(0xffC0C0C0))),
                          child: Column(
                            children: [
                              Text(
                                "الزكاة المستحقة",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Color(0xff3D3D3D),
                                    fontWeight: FontWeight.w400),
                              ),
                              Divider(),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                "00.00 \$",
                                style: TextStyle(
                                    color: Color(0xff7F7F7F),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Center(
                          child: SizedBox(
                            width: 335.w,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(kPrimaryColor),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.r)))),
                                onPressed: () {},
                                child: Text(
                                  "حساب الزكاة",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600),
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          );
        },
      ),
    );
  }
}

class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.zakahCubit,
  });

  final ZakahCubit zakahCubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: ListTile(
                        title: Text(
                          "تنبيه الزكاة",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "قبل موعد التسديد ب...",
                          style: TextStyle(
                              color: kBlackGrey,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      content: SizedBox(
                          width: 240.w,
                          height: 300.h,
                          child: ListView.separated(
                              itemBuilder: (context, index) {
                                return ZakahNotificationSwitchTile(
                                  index: index,
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  thickness: 1.1,
                                  height: 0.7.h,
                                  color: const Color(0xff889CB8),
                                );
                              },
                              itemCount: 6)),
                      actions: [
                        TextButton(
                            style: ButtonStyle(
                                textStyle: WidgetStateProperty.all(
                                    TextStyle(color: Colors.blueAccent))),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "موافق",
                              style: TextStyle(color: Colors.blueAccent),
                            )),
                      ],
                    ),
                  );
                });
          },
          child: Row(
            children: [
              Text(
                "تفعيل تنبيهات الزكاة لتذكيرك بعد...",
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: kBlackGrey),
              ),
              Text(
                "سنة",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
              ),
            ],
          ),
        ),
        Spacer(),
        CustomSwitch(
            function: (value) {
              zakahCubit.changeSwitchValue();
            },
            switchValue: zakahCubit.switchValue)
      ],
    );
  }
}

class ZakahNotificationSwitchTile extends StatefulWidget {
  const ZakahNotificationSwitchTile({
    super.key,
    required this.index,
  });

  final int index;

  @override
  State<ZakahNotificationSwitchTile> createState() =>
      _ZakahNotificationSwitchTileState();
}

class _ZakahNotificationSwitchTileState
    extends State<ZakahNotificationSwitchTile> {
  bool switchValue = false;

  @override
  void initState() {
    super.initState();
    if (CacheHelper.getData(key: "zakahNotification_${widget.index}") != null) {
      switchValue =
          CacheHelper.getData(key: "zakahNotification_${widget.index}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("${(widget.index + 1) * 5} يوم "),
        Spacer(),
        CustomSwitch(
            function: (value) {
              setState(() {
                switchValue = !switchValue;
              });
              CacheHelper.saveData(
                  key: "zakahNotification_${widget.index}", value: switchValue);
              if (switchValue) {
                LocalNotificationService.showScheduledNotificationByDate(
                    id: widget.index * 1002,
                    prayName: "تنبيه الزكاة",
                    year: 2025,
                    month: 5,
                    day: 29,
                    hour: 12,
                    minute: 00);
              } else {
                LocalNotificationService.cancelNotification(
                    widget.index * 1002);
              }
            },
            switchValue: switchValue),
      ],
    );
  }
}
