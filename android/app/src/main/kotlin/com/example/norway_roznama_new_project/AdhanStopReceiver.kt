package com.example.norway_roznama_new_project

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * BroadcastReceiver that handles Adhan stop requests from notification actions.
 * This receiver calls the AdhanForegroundService to stop playback.
 */
class AdhanStopReceiver : BroadcastReceiver() {
    
    companion object {
        const val TAG = "AdhanStopReceiver"
        const val ACTION_STOP_ADHAN = "com.example.norway_roznama_new_project.ACTION_STOP_ADHAN"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d(TAG, "Received action: $action")
        
        when (action) {
            ACTION_STOP_ADHAN, AdhanForegroundService.ACTION_STOP -> {
                Log.d(TAG, "Stop action received - stopping Adhan service")
                AdhanForegroundService.stopAdhan(context)
            }
            else -> {
                Log.d(TAG, "Unknown action: $action")
            }
        }
    }
}
