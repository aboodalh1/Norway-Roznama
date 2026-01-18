package com.islamic_mojamma.norway_roznama_new_project

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.PowerManager
import android.util.Log

/**
 * BroadcastReceiver that handles alarm triggers for Adhan playback.
 * This works even when the app is terminated because it's a native Android component.
 * 
 * Uses a static WakeLock that is handed off to the ForegroundService.
 * The service is responsible for releasing this WakeLock after it starts.
 * This prevents the device from sleeping before the service can call startForeground().
 */
class AdhanAlarmReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "AdhanAlarmReceiver"
        private const val WAKELOCK_TAG = "AdhanAlarm:ReceiverWakeLock"
        
        /**
         * Static WakeLock that persists across the receiver lifecycle.
         * The ForegroundService will release this after it acquires its own WakeLock.
         */
        @Volatile
        var receiverWakeLock: PowerManager.WakeLock? = null
            private set
        
        /**
         * Release the receiver's WakeLock. Called by the ForegroundService
         * after it has started and acquired its own WakeLock.
         */
        fun releaseReceiverWakeLock() {
            try {
                receiverWakeLock?.let {
                    if (it.isHeld) {
                        it.release()
                        Log.d(TAG, "✓ Receiver WakeLock released by service")
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing receiver WakeLock: ${e.message}")
            }
            receiverWakeLock = null
        }
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "═══ ADHAN ALARM RECEIVED ═══")
        Log.d(TAG, "════════════════════════════════════════")
        
        // Acquire WakeLock FIRST - this is critical!
        // The service will release it after starting.
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        receiverWakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            WAKELOCK_TAG
        ).apply {
            setReferenceCounted(false)
            acquire(5 * 60 * 1000L) // 5 minutes max timeout (safety net)
        }
        Log.d(TAG, "✓ Receiver WakeLock acquired (service will release)")
        
        try {
            val soundPath = intent.getStringExtra("soundPath") ?: "sounds/alafasi.mp3"
            val title = intent.getStringExtra("title") ?: "Adhan"
            val body = intent.getStringExtra("body") ?: "Prayer Time"
            val alarmId = intent.getIntExtra("alarmId", -1)
            
            Log.d(TAG, "Alarm ID: $alarmId")
            Log.d(TAG, "Sound path: $soundPath")
            Log.d(TAG, "Title: $title")
            
            // Start the foreground service to play adhan
            // The service will:
            // 1. Call startForeground() immediately
            // 2. Acquire its own WakeLock
            // 3. Release this receiver's WakeLock
            // 4. Play the audio
            AdhanForegroundService.startAdhan(context, soundPath, title, body)
            
            Log.d(TAG, "✓ Foreground service start command sent")
            
        } catch (e: Exception) {
            Log.e(TAG, "✗ ERROR starting Adhan service: ${e.message}", e)
            // Release WakeLock on error since service won't do it
            releaseReceiverWakeLock()
        }
        
        // NOTE: WakeLock is NOT released here!
        // The service will release it after it starts successfully.
        // This prevents the device from sleeping during the async service start.
        
        Log.d(TAG, "════════════════════════════════════════")
    }
}
