import 'dart:async';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/util/service_locator.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/qiblah/data/repos/qiblah_repo_impl.dart';
import 'package:norway_roznama_new_project/features/prays_and_times/prays_and_qiblah/qiblah/presentation/manger/qiblah_cubit.dart';
import 'dart:math' as Math;

import '../../../../../../core/util/constant.dart';
import '../../../presentation/view/prays_and_qiblah_page.dart';

class QiblahCard extends StatefulWidget {
  const QiblahCard({
    super.key,
  });

  @override
  State<QiblahCard> createState() => _QiblahCardState();
}

class _QiblahCardState extends State<QiblahCard> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool hasCompass = false;
  double heading = 0.0;
  final double qiblahLat = 21.422510;
  final double qiblahLon = 39.826174;
  double userLat = latitude; // Replace with actual latitude
  double userLon = longitude; // Replace with actual longitude
  late StreamSubscription<CompassEvent> _compassSubscription;

  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double lat1Rad = lat1 * (3.141592653589793 / 180); // Convert to radians
    double lon1Rad = lon1 * (3.141592653589793 / 180);
    double lat2Rad = lat2 * (3.141592653589793 / 180);
    double lon2Rad = lon2 * (3.141592653589793 / 180);

    double dLon = lon2Rad - lon1Rad;

    double y = Math.sin(dLon) * Math.cos(lat2Rad);

    double x = Math.cos(lat1Rad) * Math.sin(lat2Rad) -
        Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLon);

    double bearing = Math.atan2(y, x); // Bearing in radians

    bearing = bearing * (180 / 3.141592653589793); // Convert to degrees

    return (bearing + 360) % 360; // Normalize to 0-360 degrees
  }

  double qiblahBearing = 0;

  @override
  void initState() {
    super.initState();
    FlutterCompass.events!.first.then((event) {
      if (event.heading == null) {
        // No compass available on this device
        setState(() {
          hasCompass = false;
        });
      } else {
        // Device has a compass
        setState(() {
          hasCompass = true;
        });

        _compassSubscription = FlutterCompass.events!.listen((event) {
          if (!mounted) return;
          setState(() {
            heading = event.heading ?? 0.0;
            qiblahBearing =
                calculateBearing(qiblahLat, qiblahLon, userLat, userLon);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _compassSubscription.cancel(); // Cancel the compass stream subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QiblahCubit(getIt.get<QiblahRepoImpl>()),
      child: BlocBuilder<QiblahCubit, QiblahState>(
        builder: (context, state) {
          QiblahCubit qiblahCubit = context.read<QiblahCubit>();
          return state is GetQiblahFailure
              ? QiblahErrorWidget(error: state.error, qiblahCubit: qiblahCubit)
              : state is GetQiblahLoading
                  ? PrayOrLocationLoadingWidget()
                  : Container(
                      width: double.infinity,
                      height: 278.h,
                      decoration: const BoxDecoration(color: Color(0xffD9D9D9)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0.w, vertical: 5.h),
                        child: false
                            ? FancyShimmerImage(
                                boxFit: BoxFit.fitHeight,
                                imageUrl:
                                    'https://api.aladhan.com/v1/qibla/$latitude/$longitude/compass',
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(
                                        'assets/icons/location.png',
                                        height: 40.h,
                                      ),
                                    ],
                                  ),
                                  Transform.rotate(
                                    angle: ((qiblahBearing - heading) *
                                        (3.141592653589793 / 180)),
                                    // Convert degrees to radians
                                    child: Column(
                                      children: [
                                        heading == null
                                            ? CircularProgressIndicator(
                                                color: kPrimaryColor,
                                              ) // Loading indicator while heading is null
                                            : Image.asset(
                                                'assets/icons/locator.png',
                                                height: 40,
                                              ),
                                        Container(
                                          width: 5.w,
                                          color: kPrimaryColor,
                                          height: 60.h,
                                        ),
                                        Image.asset(
                                          'assets/icons/kaba.png',
                                          height: 40.h,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
        },
      ),
    );
  }
}

class QiblahErrorWidget extends StatelessWidget {
  const QiblahErrorWidget({
    super.key,
    required this.qiblahCubit,
    required this.error,
  });

  final QiblahCubit qiblahCubit;
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          SizedBox(
            height: 20.h,
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(kPrimaryColor)),
              onPressed: () {
                qiblahCubit.getQiblah();
              },
              child: Text(
                "إعادة المحاولة",
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ))
        ],
      ),
    );
  }
}
