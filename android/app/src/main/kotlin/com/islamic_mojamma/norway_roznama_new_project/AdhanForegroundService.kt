package com.islamic_mojamma.norway_roznama_new_project

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import java.io.File

/**
 * Foreground Service that manages Adhan audio playback and notification.
 */
class AdhanForegroundService : Service() {

    companion object {
        private const val TAG = "AdhanForegroundService"
        
        const val CHANNEL_ID = "adhan_foreground_channel"
        const val CHANNEL_NAME = "Adhan Playback"
        const val NOTIFICATION_ID = 7777
        
        const val ACTION_PLAY = "com.islamic_mojamma.norway_roznama_new_project.ACTION_PLAY_ADHAN"
        const val ACTION_STOP = "com.islamic_mojamma.norway_roznama_new_project.ACTION_STOP_ADHAN"
        
        const val EXTRA_SOUND_PATH = "sound_path"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        
        @Volatile
        var isRunning = false
            private set
        
        fun startAdhan(context: Context, soundPath: String, title: String, body: String) {
            Log.d(TAG, "startAdhan() called - soundPath: $soundPath")
            // Debug Toast
            Handler(Looper.getMainLooper()).post {
                Toast.makeText(context, "Starting Adhan Service...", Toast.LENGTH_SHORT).show()
            }
            
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
        
        fun stopAdhan(context: Context) {
            Log.d(TAG, "stopAdhan() called")
            val intent = Intent(context, AdhanForegroundService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }
    
    private var mediaPlayer: MediaPlayer? = null
    private var notificationManager: NotificationManager? = null
    private var serviceWakeLock: PowerManager.WakeLock? = null
    
    private val stopReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            Log.d(TAG, "Stop broadcast received from notification")
            stopPlayback()
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "════════════════════════════════════════")
        Log.d(TAG, "═══ SERVICE CREATED ═══")
        Log.d(TAG, "════════════════════════════════════════")
        
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        createNotificationChannel()
        
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        serviceWakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "AdhanService:PlaybackWakeLock"
        ).apply {
            setReferenceCounted(false)
        }
        
        val filter = IntentFilter(ACTION_STOP)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(stopReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(stopReceiver, filter)
        }
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: action=${intent?.action}")
        AdhanAlarmReceiver.releaseReceiverWakeLock()
        
        when (intent?.action) {
            ACTION_PLAY -> {
                val soundPath = intent.getStringExtra(EXTRA_SOUND_PATH) ?: "alafasi.mp3"
                val title = intent.getStringExtra(EXTRA_TITLE) ?: "Adhan"
                val body = intent.getStringExtra(EXTRA_BODY) ?: "Prayer Time"
                
                // Show notification immediately to satisfy FGS requirement
                val notification = createNotification(title, body)
                startForeground(NOTIFICATION_ID, notification)
                
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
        Log.d(TAG, "═══ SERVICE DESTROYED ═══")
        isRunning = false
        
        try {
            unregisterReceiver(stopReceiver)
        } catch (e: Exception) {
            Log.w(TAG, "Error unregistering receiver: ${e.message}")
        }
        
        releaseMediaPlayer()
        releaseServiceWakeLock()
        AdhanAlarmReceiver.releaseReceiverWakeLock()
        
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
                setSound(null, null)
                enableVibration(true)
                enableLights(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            notificationManager?.createNotificationChannel(channel)
        }
    }
    
    private fun startPlayback(soundPath: String, title: String, body: String) {
        Log.d(TAG, "startPlayback: $soundPath")
        
        serviceWakeLock?.acquire(30 * 60 * 1000L)
        releaseMediaPlayer()
        isRunning = true
        
        // Check file exists
        val file = File(soundPath)
        if (!file.exists()) {
            Log.e(TAG, "FILE NOT FOUND: $soundPath")
            Handler(Looper.getMainLooper()).post {
                Toast.makeText(applicationContext, "Error: Audio file not found", Toast.LENGTH_LONG).show()
            }
            updateNotification(title, "Error: Audio file not found")
            return
        }
        
        try {
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .build()
                )
                
                setDataSource(soundPath)
                isLooping = true
                setVolume(1.0f, 1.0f)
                
                setOnPreparedListener {
                    Log.d(TAG, "MediaPlayer prepared, starting")
                    start()
                    Handler(Looper.getMainLooper()).post {
                        Toast.makeText(applicationContext, "Adhan Playing", Toast.LENGTH_SHORT).show()
                    }
                }
                
                setOnErrorListener { _, what, extra ->
                    Log.e(TAG, "MediaPlayer Error: $what, $extra")
                    updateNotification(title, "Error playing audio")
                    Handler(Looper.getMainLooper()).post {
                        Toast.makeText(applicationContext, "Playback Error: $what", Toast.LENGTH_LONG).show()
                    }
                    true
                }
                
                prepareAsync()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error starting playback", e)
            updateNotification(title, "Error: ${e.message}")
            Handler(Looper.getMainLooper()).post {
                Toast.makeText(applicationContext, "Error: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }
    
    private fun updateNotification(title: String, body: String) {
        val notification = createNotification(title, body)
        notificationManager?.notify(NOTIFICATION_ID, notification)
    }
    
    private fun createNotification(title: String, body: String): Notification {
        val stopIntent = Intent(this, AdhanStopReceiver::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setAutoCancel(false)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .addAction(android.R.drawable.ic_media_pause, "Stop / إيقاف", stopPendingIntent)
            .setDeleteIntent(stopPendingIntent)
            .build()
    }
    
    private fun stopPlayback() {
        Log.d(TAG, "Stopping playback")
        isRunning = false
        releaseMediaPlayer()
        releaseServiceWakeLock()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        
        stopSelf()
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(applicationContext, "Adhan Stopped", Toast.LENGTH_SHORT).show()
        }
    }
    
    private fun releaseMediaPlayer() {
        mediaPlayer?.let {
            try {
                it.release()
            } catch (e: Exception) {
                Log.w(TAG, "Error releasing MediaPlayer: ${e.message}")
            }
        }
        mediaPlayer = null
    }
    
    private fun releaseServiceWakeLock() {
        try {
            serviceWakeLock?.let {
                if (it.isHeld) it.release()
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error releasing WakeLock: ${e.message}")
        }
    }
}
