package com.islamic_mojamma.norway_roznama_new_project

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.islamic_mojamma.norway_roznama_new_project/adhan_service"
    private val TAG = "MainActivity"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up MethodChannel for Adhan Foreground Service control
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "MethodChannel call: ${call.method}")
            
            when (call.method) {
                "playAdhan" -> {
                    val soundPath = call.argument<String>("soundPath") ?: "sounds/alafasi.mp3"
                    val title = call.argument<String>("title") ?: "Adhan"
                    val body = call.argument<String>("body") ?: "Prayer Time"
                    
                    Log.d(TAG, "Playing Adhan: $soundPath, $title")
                    AdhanForegroundService.startAdhan(applicationContext, soundPath, title, body)
                    result.success(true)
                }
                "stopAdhan" -> {
                    Log.d(TAG, "Stopping Adhan")
                    AdhanForegroundService.stopAdhan(applicationContext)
                    result.success(true)
                }
                "isPlaying" -> {
                    val isPlaying = AdhanForegroundService.isRunning
                    Log.d(TAG, "Is playing: $isPlaying")
                    result.success(isPlaying)
                }
                "scheduleNativeAlarm" -> {
                    val alarmId = call.argument<Int>("alarmId") ?: 0
                    val triggerTime = call.argument<Long>("triggerTime") ?: 0L
                    val soundPath = call.argument<String>("soundPath") ?: "sounds/alafasi.mp3"
                    val title = call.argument<String>("title") ?: "Adhan"
                    val body = call.argument<String>("body") ?: "Prayer Time"
                    
                    Log.d(TAG, "Scheduling native alarm - id: $alarmId, time: $triggerTime")
                    AdhanAlarmScheduler.scheduleAlarm(
                        applicationContext,
                        alarmId,
                        triggerTime,
                        soundPath,
                        title,
                        body
                    )
                    result.success(true)
                }
                "cancelNativeAlarm" -> {
                    val alarmId = call.argument<Int>("alarmId") ?: 0
                    
                    Log.d(TAG, "Cancelling native alarm - id: $alarmId")
                    AdhanAlarmScheduler.cancelAlarm(applicationContext, alarmId)
                    result.success(true)
                }
                "canScheduleExactAlarms" -> {
                    val canSchedule = AdhanAlarmScheduler.canScheduleExactAlarms(applicationContext)
                    Log.d(TAG, "Can schedule exact alarms: $canSchedule")
                    result.success(canSchedule)
                }
                else -> {
                    Log.w(TAG, "Unknown method: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }
}

