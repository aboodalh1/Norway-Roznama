import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../../core/util/constant.dart';
import '../../../../prays_and_qiblah/presentation/manger/prays_cubit.dart';


class PrayerBigClock extends StatefulWidget {
  const PrayerBigClock({super.key, required this.index, required this.praysCubit});
  final int index;
  final PraysCubit praysCubit;

  @override
  _PrayerBigClockState createState() => _PrayerBigClockState();
}

class _PrayerBigClockState extends State<PrayerBigClock> {
  late Timer _timer;
   Duration _remainingTime=Duration(seconds: 0);
  late DateTime _prayerTime;
  late int _totalSeconds;
  double _progress = 0.0; // Start full

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  void _initializeCountdown() {


    DateTime now = DateTime.now();
    _prayerTime = widget.praysCubit.datePraysTimes[widget.index];
    if (_prayerTime.isBefore(now)) {
      _prayerTime = _prayerTime.add(const Duration(days: 1));
    }

    // Calculate total seconds
    _totalSeconds = _prayerTime.difference(now).inSeconds;


    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });

  }

  void _updateCountdown() {
    setState(() {
      _remainingTime = _prayerTime.difference(DateTime.now());
      if (_remainingTime.isNegative) {
        _timer.cancel();
        _remainingTime = Duration.zero;
        _progress = 0.0;
      } else {

        _progress = (_totalSeconds - _remainingTime.inSeconds) / _totalSeconds;

      }
    });
  }

  String _formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {

    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      circularStrokeCap: CircularStrokeCap.round,
      arcType: ArcType.FULL_REVERSED,
      radius: 95.0.r,
      lineWidth: 15.0.w,
      animation: true,
      animateFromLastPercent: true,
      percent: _remainingTime.inMinutes < 0 ? 0 : _progress, // Dynamic percentage update
      animateToInitialPercent: false, // Disable animation to prevent flickering
      widgetIndicator: Icon(Icons.circle, color: Colors.grey.shade200, size: 30.sp),
      center: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: kGreyColor,
          shape: BoxShape.circle
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('الوقت المتبقي', style: TextStyle(fontSize: 18.sp, color: Colors.black)),
            Text(
              widget.praysCubit.praysName[widget.index],
              style: TextStyle(fontSize: 22.sp, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Text(
              _formatDuration(_remainingTime),
              style: TextStyle(fontSize: 20.sp, color: const Color(0xff3766A7)),
            ),
          ],
        ),
      ),
      progressColor: Colors.pink,
      backgroundColor: Colors.grey.shade300,
    );
  }
}
