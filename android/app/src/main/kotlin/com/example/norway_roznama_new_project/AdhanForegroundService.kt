package com.example.norway_roznama_new_project

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.AssetFileDescriptor
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * Foreground Service that manages Adhan audio playback and notification.
 * This service owns both the MediaPlayer and notification, ensuring they stay in sync.
 * The stop button works even when the app is terminated because this service runs independently.
 */
class AdhanForegroundService : Service() {

    companion object {
        private const val TAG = "AdhanForegroundService"
        
        const val CHANNEL_ID = "adhan_foreground_channel"
        const val CHANNEL_NAME = "Adhan Playback"
        const val NOTIFICATION_ID = 7777
        
        const val ACTION_PLAY = "com.example.norway_roznama_new_project.ACTION_PLAY_ADHAN"
        const val ACTION_STOP = "com.example.norway_roznama_new_project.ACTION_STOP_ADHAN"
        
        const val EXTRA_SOUND_PATH = "sound_path"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        
        // Static flag to check if service is running
        @Volatile
        var isRunning = false
            private set
        
        /**
         * Start the Adhan playback service
         */
        fun startAdhan(context: Context, soundPath: String, title: String, body: String) {
            Log.d(TAG, "Starting Adhan service: $soundPath")
            val intent = Intent(context, AdhanForegroundService::class.java).apply {
                action = ACTION_PLAY
                putExtra(EXTRA_SOUND_PATH, soundPath)
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_BODY, body)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
        
        /**
         * Stop the Adhan playback service
         */
        fun stopAdhan(context: Context) {
            Log.d(TAG, "Stopping Adhan service")
            val intent = Intent(context, AdhanForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }
    
    private var mediaPlayer: MediaPlayer? = null
    private var notificationManager: NotificationManager? = null
    
    // BroadcastReceiver for stop action from notification
    private val stopReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.d(TAG, "Stop broadcast received")
            stopPlayback()
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        
        // Register stop receiver
        val filter = IntentFilter(ACTION_STOP)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(stopReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(stopReceiver, filter)
        }
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: action=${intent?.action}")
        
        when (intent?.action) {
            ACTION_PLAY -> {
                val soundPath = intent.getStringExtra(EXTRA_SOUND_PATH) ?: "alafasi.mp3"
                val title = intent.getStringExtra(EXTRA_TITLE) ?: "Adhan"
                val body = intent.getStringExtra(EXTRA_BODY) ?: "Prayer Time"
                
                startPlayback(soundPath, title, body)
            }
            ACTION_STOP -> {
                stopPlayback()
            }
            else -> {
                Log.w(TAG, "Unknown action: ${intent?.action}")
            }
        }
        
        return START_NOT_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        Log.d(TAG, "Service destroyed")
        isRunning = false
        
        try {
            unregisterReceiver(stopReceiver)
        } catch (e: Exception) {
            Log.w(TAG, "Error unregistering receiver: ${e.message}")
        }
        
        releaseMediaPlayer()
        super.onDestroy()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Adhan playback notifications"
                setSound(null, null) // No notification sound - we play our own audio
                enableVibration(true)
                enableLights(true)
            }
            notificationManager?.createNotificationChannel(channel)
            Log.d(TAG, "Notification channel created")
        }
    }
    
    private fun startPlayback(soundPath: String, title: String, body: String) {
        Log.d(TAG, "Starting playback: $soundPath")
        
        // Stop any existing playback
        releaseMediaPlayer()
        
        // Create notification first (required for foreground service)
        // This ensures notification shows even if playback fails
        val notification = createNotification(title, body)
        startForeground(NOTIFICATION_ID, notification)
        isRunning = true
        Log.d(TAG, "Foreground service started with notification")
        
        try {
            // Initialize and start MediaPlayer
            mediaPlayer = MediaPlayer().apply {
                // The Dart side now always provides a file system path
                // (either original file or temp copy of asset)
                val file = java.io.File(soundPath)
                if (!file.exists() || !file.isFile) {
                    throw Exception("File not found: $soundPath")
                }
                
                Log.d(TAG, "Loading from file system: $soundPath (size: ${file.length()} bytes)")
                setDataSource(soundPath)
                
                isLooping = true
                setVolume(1.0f, 1.0f)
                
                setOnPreparedListener {
                    Log.d(TAG, "MediaPlayer prepared, starting playback")
                    start()
                }
                
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer error: what=$what, extra=$extra")
                    // Update notification to show error
                    updateNotification(title, "Error playing audio", false)
                    stopPlayback()
                    true
                }
                
                setOnCompletionListener {
                    Log.d(TAG, "MediaPlayer completed")
                    // Don't stop if looping
                }
                
                prepareAsync()
            }
            
            Log.d(TAG, "MediaPlayer created and preparing")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting playback: ${e.message}", e)
            e.printStackTrace()
            // Update notification to show error but keep service running
            updateNotification(title, "Error: ${e.message}", false)
            // Don't stop immediately - let user see the error notification
            // stopPlayback()
        }
    }
    
    private fun updateNotification(title: String, body: String, isPlaying: Boolean) {
        val notification = createNotification(title, body)
        notificationManager?.notify(NOTIFICATION_ID, notification)
    }
    
    private fun createNotification(title: String, body: String): Notification {
        // Create stop action PendingIntent
        val stopIntent = Intent(ACTION_STOP).apply {
            setPackage(packageName)
        }
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Create notification with stop action
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setAutoCancel(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .addAction(
                android.R.drawable.ic_media_pause,
                "Stop",
                stopPendingIntent
            )
            .setDeleteIntent(stopPendingIntent) // Also stop when notification is dismissed
            .build()
    }
    
    private fun stopPlayback() {
        Log.d(TAG, "Stopping playback")
        
        isRunning = false
        releaseMediaPlayer()
        
        // Stop foreground and remove notification
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        
        // Stop the service
        stopSelf()
        
        Log.d(TAG, "Playback stopped and service stopping")
    }
    
    private fun releaseMediaPlayer() {
        mediaPlayer?.let {
            try {
                if (it.isPlaying) {
                    it.stop()
                }
                it.release()
                Log.d(TAG, "MediaPlayer released")
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing MediaPlayer: ${e.message}")
            }
        }
        mediaPlayer = null
    }
}

