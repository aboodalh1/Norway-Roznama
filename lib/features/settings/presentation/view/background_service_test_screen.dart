import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:norway_roznama_new_project/core/audio/adhan_service.dart';
import 'package:norway_roznama_new_project/core/audio/test_alarm_scheduler.dart';
import 'package:norway_roznama_new_project/core/util/constant.dart';

class BackgroundServiceTestScreen extends StatefulWidget {
  const BackgroundServiceTestScreen({super.key});

  @override
  State<BackgroundServiceTestScreen> createState() =>
      _BackgroundServiceTestScreenState();
}

class _BackgroundServiceTestScreenState
    extends State<BackgroundServiceTestScreen> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  bool _isScheduled = false;
  DateTime? _scheduledTime;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _addLog('Ready to test native Foreground Service');
    _addLog('Stop button works even when app is terminated!');
  }

  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    setState(() {
      _logs.add('[$timestamp] $message');
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _scheduleAlarm() async {
    _addLog('🚀 Scheduling test alarm...');

    try {
      const delay = Duration(seconds: 15);
      final result = await scheduleTestAlarm(delay: delay);

      if (result) {
        _scheduledTime = DateTime.now().add(delay);

        setState(() {
          _isScheduled = true;
          _remainingSeconds = delay.inSeconds;
        });

        _addLog(
            '✅ Alarm scheduled for ${_scheduledTime!.toString().substring(11, 19)}');
        _addLog('📱 You can now close the app - alarm will still fire!');
        _addLog('🔔 Native Foreground Service will handle playback');

        // Start countdown timer
        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            _remainingSeconds--;
          });

          if (_remainingSeconds > 0) {
            _addLog('⏱️ ${_remainingSeconds}s remaining...');
          } else {
            timer.cancel();
            _addLog('⏰ Alarm should fire now!');
            setState(() {
              _isScheduled = false;
            });
          }
        });
      } else {
        _addLog('❌ Failed to schedule alarm');
      }
    } catch (e, stackTrace) {
      _addLog('❌ Error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _cancelAlarm() async {
    _addLog('🗑️ Cancelling alarm...');

    try {
      await cancelTestAlarm();
      _countdownTimer?.cancel();

      setState(() {
        _isScheduled = false;
        _scheduledTime = null;
        _remainingSeconds = 0;
      });

      _addLog('✅ Alarm cancelled');
    } catch (e) {
      _addLog('❌ Error cancelling: $e');
    }
  }

  Future<void> _stopAdhan() async {
    _addLog('🛑 Stopping Adhan via native service...');

    try {
      final result = await AdhanService.stop();
      if (result) {
        _addLog('✅ Adhan stopped');
      } else {
        _addLog('⚠️ Stop command sent (may not be playing)');
      }
    } catch (e) {
      _addLog('❌ Error stopping: $e');
    }
  }

  Future<void> _testImmediatePlay() async {
    _addLog('🎵 Testing immediate playback (native service)...');

    try {
      final result = await AdhanService.play(
        soundPath: 'sounds/alafasi.mp3',
        title: 'Immediate Test',
        body: 'Testing native Foreground Service',
      );

      if (result) {
        _addLog('✅ Playing now via native Foreground Service');
        _addLog('🛑 Use notification Stop button to stop');
      } else {
        _addLog('❌ Failed to start playback');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    }
  }

  Future<void> _checkStatus() async {
    try {
      final isPlaying = await AdhanService.isPlaying();
      _addLog('📊 Status: ${isPlaying ? "Playing" : "Not playing"}');
    } catch (e) {
      _addLog('❌ Error checking status: $e');
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
    _addLog('Logs cleared');
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'اختبار خدمة الأذان',
            style: TextStyle(fontSize: 20.sp, color: Colors.white),
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                color:
                    _isScheduled ? Colors.orange.shade50 : Colors.grey.shade100,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isScheduled
                                ? Icons.schedule
                                : Icons.schedule_outlined,
                            color: _isScheduled ? Colors.orange : Colors.grey,
                            size: 32.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            _isScheduled
                                ? 'مجدول (${_remainingSeconds}s)'
                                : 'غير مجدول',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: _isScheduled ? Colors.orange : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (_isScheduled && _scheduledTime != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'سيعمل في ${_scheduledTime!.toString().substring(11, 19)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'يمكنك إغلاق التطبيق - سيعمل المنبه!',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Main Control Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isScheduled ? null : _scheduleAlarm,
                      icon: const Icon(Icons.schedule),
                      label: const Text('جدولة (15 ثانية)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isScheduled ? _cancelAlarm : null,
                      icon: const Icon(Icons.cancel),
                      label: const Text('إلغاء'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Secondary Control Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _testImmediatePlay,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('تشغيل فوري'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _stopAdhan,
                      icon: const Icon(Icons.stop),
                      label: const Text('إيقاف الأذان'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Status Check Button
              OutlinedButton.icon(
                onPressed: _checkStatus,
                icon: const Icon(Icons.info_outline),
                label: const Text('فحص الحالة'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
              SizedBox(height: 16.h),

              // Logs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سجل الأحداث:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearLogs,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('مسح'),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Log Display
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: _logs.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد أحداث',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14.sp,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            Color textColor = Colors.green.shade300;
                            if (log.contains('❌')) {
                              textColor = Colors.red.shade300;
                            } else if (log.contains('⚠️')) {
                              textColor = Colors.orange.shade300;
                            } else if (log.contains('⏱️')) {
                              textColor = Colors.blue.shade300;
                            }

                            return Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Text(
                                log,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12.sp,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),

              SizedBox(height: 12.h),

              // Instructions
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تعليمات الاختبار:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '1. اضغط "جدولة" لجدولة المنبه بعد 15 ثانية\n'
                      '2. أغلق التطبيق تماماً (أزله من التطبيقات الأخيرة)\n'
                      '3. انتظر - سيعمل الأذان بعد 15 ثانية\n'
                      '4. اضغط "إيقاف" في الإشعار لإيقاف الأذان\n'
                      '✓ يعمل زر الإيقاف حتى عند إغلاق التطبيق!',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
