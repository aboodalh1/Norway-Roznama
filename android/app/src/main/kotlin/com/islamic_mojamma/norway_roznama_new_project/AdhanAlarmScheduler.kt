package com.islamic_mojamma.norway_roznama_new_project

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Native alarm scheduler for Adhan.
 * Uses Android's AlarmManager directly to schedule alarms that work even when the app is terminated.
 */
object AdhanAlarmScheduler {
    
    private const val TAG = "AdhanAlarmScheduler"
    
    /**
     * Schedule an alarm to play Adhan at the specified time.
     * 
     * @param context Application context
     * @param alarmId Unique ID for this alarm (used for cancellation)
     * @param triggerTimeMillis Unix timestamp in milliseconds when alarm should fire
     * @param soundPath Path to the audio file (temp file path)
     * @param title Notification title
     * @param body Notification body text
     */
    fun scheduleAlarm(
        context: Context,
        alarmId: Int,
        triggerTimeMillis: Long,
        soundPath: String,
        title: String,
        body: String
    ) {
        Log.d(TAG, "Scheduling alarm - id: $alarmId, time: $triggerTimeMillis, sound: $soundPath")
        
        val intent = Intent(context, AdhanAlarmReceiver::class.java).apply {
            putExtra("soundPath", soundPath)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("alarmId", alarmId)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        
        // Use setAlarmClock for highest priority - this will wake the device and show alarm icon
        val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerTimeMillis, pendingIntent)
        alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
        
        Log.d(TAG, "Alarm scheduled successfully for id: $alarmId")
    }
    
    /**
     * Cancel a scheduled alarm.
     * 
     * @param context Application context
     * @param alarmId ID of the alarm to cancel
     */
    fun cancelAlarm(context: Context, alarmId: Int) {
        Log.d(TAG, "Cancelling alarm - id: $alarmId")
        
        val intent = Intent(context, AdhanAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
        
        Log.d(TAG, "Alarm cancelled for id: $alarmId")
    }
    
    /**
     * Check if exact alarms are allowed (Android 12+)
     */
    fun canScheduleExactAlarms(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.canScheduleExactAlarms()
        } else {
            true // Permission not required before Android 12
        }
    }
}

