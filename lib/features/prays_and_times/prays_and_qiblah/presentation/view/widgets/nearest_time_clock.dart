import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../../core/util/constant.dart';
import '../../manger/prays_cubit.dart';

class NearestTimeClock extends StatefulWidget {
  const NearestTimeClock({super.key, required this.praysCubit});

  final PraysCubit praysCubit;

  @override
  _NearestTimeClockState createState() => _NearestTimeClockState();
}
  
class _NearestTimeClockState extends State<NearestTimeClock> {
  late Timer _timer;
  Duration _remainingTime = Duration(minutes: 0);
  late DateTime _nearestPrayTime;
  late int _totalMinutes;
  double _progress = 0.0; // Start full

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  void _initializeCountdown() {
    Future.delayed(Duration(seconds: 2), () {
      DateTime now = DateTime.now();
      _nearestPrayTime = widget.praysCubit.getNearestPrayTime()!;
      if (_nearestPrayTime.isBefore(now)) {
        _nearestPrayTime = _nearestPrayTime.add(const Duration(days: 1));
      }
      _totalMinutes = widget.praysCubit.neartestPrayIndex == 0
          ? _nearestPrayTime.day == widget.praysCubit.datePraysTimes[6].day
              ? (now.difference(_nearestPrayTime).inMinutes * -1)
              : (_nearestPrayTime 
                  .difference(widget.praysCubit.datePraysTimes[6])
                  .inMinutes)
          : _nearestPrayTime
              .difference(widget.praysCubit
                  .datePraysTimes[widget.praysCubit.neartestPrayIndex - 1])
              .inMinutes;
      _updateCountdown();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateCountdown();
      });
    });
  }

  void _updateCountdown() {
    setState(() {
      _remainingTime = _nearestPrayTime.difference(DateTime.now());
      if (_remainingTime.isNegative) {
        _timer.cancel();
        _remainingTime = Duration.zero;
        _progress = 0.0;
      } else {
        _progress = (_totalMinutes - _remainingTime.inMinutes) / _totalMinutes;
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
      percent: _remainingTime.inMinutes < 0 ? 0 : _progress>=0 &&_progress<=1?_progress:0.0,
      animateToInitialPercent: false,
      // Disable animation to prevent flickering
      widgetIndicator:
          Icon(Icons.circle, color: Colors.grey.shade200, size: 25.sp),
      center: Container(
        width: 160.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kGreyColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('الوقت المتبقي',
                style: TextStyle(fontSize: 18.sp, color: Colors.black)),
            Text(
              widget.praysCubit.praysName[widget.praysCubit.neartestPrayIndex],
              style: TextStyle(
                  fontSize: 22.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
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
