package com.example.norway_roznama_new_project

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * BroadcastReceiver that handles alarm triggers for Adhan playback.
 * This works even when the app is terminated because it's a native Android component.
 */
class AdhanAlarmReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "AdhanAlarmReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Alarm received!")
        
        val soundPath = intent.getStringExtra("soundPath") ?: "sounds/alafasi.mp3"
        val title = intent.getStringExtra("title") ?: "Adhan"
        val body = intent.getStringExtra("body") ?: "Prayer Time"
        
        Log.d(TAG, "Starting Adhan service - soundPath: $soundPath, title: $title")
        
        // Start the foreground service to play adhan
        // This works even when the app is completely terminated
        AdhanForegroundService.startAdhan(context, soundPath, title, body)
    }
}

