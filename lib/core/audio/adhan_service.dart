import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Native Adhan Foreground Service interface.
///
/// This class communicates with the Android AdhanForegroundService via MethodChannel.
/// The native service owns the MediaPlayer and notification, ensuring they stay in sync.
/// Stop button works even when app is terminated because the service runs independently.
class AdhanService {
  static const MethodChannel _channel = MethodChannel(
    'com.islamic_mojamma.norway_roznama_new_project/adhan_service',
  );

  /// Cache for copied asset files to avoid re-copying
  static final Map<String, String> _assetCache = {};

  /// Play Adhan using the native foreground service.
  ///
  /// [soundPath] - Path to the audio file in assets (e.g., "sounds/alafasi.mp3" or "assets/sounds/alafasi.mp3")
  /// [title] - Notification title
  /// [body] - Notification body text
  static Future<bool> play({
    required String soundPath,
    String title = 'Adhan',
    String body = 'Prayer Time',
  }) async {
    print('🔊 [AdhanService] Playing: $soundPath');

    try {
      // Prepare the asset file (copies to permanent storage if needed)
      final finalPath = await _prepareAssetFile(soundPath);

      if (finalPath == null) {
        print('❌ [AdhanService] Failed to prepare asset file');
        return false;
      }

      final result = await _channel.invokeMethod<bool>('playAdhan', {
        'soundPath': finalPath,
        'title': title,
        'body': body,
      });

      print('✅ [AdhanService] Play command sent, result: $result');
      return result ?? false;
    } catch (e) {
      print('❌ [AdhanService] Error playing: $e');
      return false;
    }
  }

  /// Stop Adhan playback.
  ///
  /// This stops the native foreground service, which:
  /// - Stops the MediaPlayer
  /// - Removes the notification
  /// - Stops the service
  static Future<bool> stop() async {
    print('🛑 [AdhanService] Stopping');

    try {
      final result = await _channel.invokeMethod<bool>('stopAdhan');
      print('✅ [AdhanService] Stop command sent, result: $result');
      return result ?? false;
    } catch (e) {
      print('❌ [AdhanService] Error stopping: $e');
      return false;
    }
  }

  /// Check if Adhan is currently playing.
  static Future<bool> isPlaying() async {
    try {
      final result = await _channel.invokeMethod<bool>('isPlaying');
      return result ?? false;
    } catch (e) {
      print('⚠️ [AdhanService] Error checking status: $e');
      return false;
    }
  }

  /// Schedule an Adhan alarm using native Android AlarmManager.
  ///
  /// This works even when the app is terminated because it uses native Android
  /// AlarmManager directly, which triggers AdhanAlarmReceiver -> AdhanForegroundService.
  ///
  /// Returns false if exact alarms cannot be scheduled (Android 12+ permission denied).
  ///
  /// [alarmId] - Unique ID for this alarm (used for cancellation)
  /// [scheduledTime] - When the alarm should fire
  /// [soundPath] - Path to the audio file in assets (e.g., "sounds/alafasi.mp3")
  /// [title] - Notification title
  /// [body] - Notification body text
  static Future<bool> schedule({
    required int alarmId,
    required DateTime scheduledTime,
    required String soundPath,
    String title = 'Adhan',
    String body = 'Prayer Time',
  }) async {
    print(
        '📅 [AdhanService] Scheduling alarm - id: $alarmId, time: $scheduledTime');

    try {
      // Check if exact alarms are allowed (Android 12+ requires user permission)
      final canSchedule = await canScheduleExactAlarms();
      if (!canSchedule) {
        print(
            '❌ [AdhanService] Exact alarms not allowed - permission denied on Android 12+');
        print(
            '⚠️ [AdhanService] User needs to enable "Alarms & reminders" permission in app settings');
        return false;
      }

      // Prepare the asset file first (copy to temp directory)
      // This is necessary because the native service needs a file path
      final filePath = await _prepareAssetFile(soundPath);

      if (filePath == null) {
        print('❌ [AdhanService] Failed to prepare asset file');
        return false;
      }

      print('📁 [AdhanService] Using file path: $filePath');

      final result = await _channel.invokeMethod<bool>('scheduleNativeAlarm', {
        'alarmId': alarmId,
        'triggerTime': scheduledTime.millisecondsSinceEpoch,
        'soundPath': filePath,
        'title': title,
        'body': body,
      });

      print('✅ [AdhanService] Schedule result: $result');
      return result ?? false;
    } catch (e) {
      print('❌ [AdhanService] Error scheduling: $e');
      return false;
    }
  }

  /// Cancel a scheduled Adhan alarm.
  ///
  /// [alarmId] - ID of the alarm to cancel
  static Future<bool> cancel(int alarmId) async {
    print('🗑️ [AdhanService] Cancelling alarm - id: $alarmId');

    try {
      final result = await _channel.invokeMethod<bool>('cancelNativeAlarm', {
        'alarmId': alarmId,
      });

      print('✅ [AdhanService] Cancel result: $result');
      return result ?? false;
    } catch (e) {
      print('❌ [AdhanService] Error cancelling: $e');
      return false;
    }
  }

  /// Check if the app can schedule exact alarms (Android 12+).
  ///
  /// On Android 12+, the SCHEDULE_EXACT_ALARM permission may need to be granted
  /// by the user in system settings.
  static Future<bool> canScheduleExactAlarms() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return result ?? true;
    } catch (e) {
      print('⚠️ [AdhanService] Error checking exact alarm permission: $e');
      return true; // Assume allowed on error
    }
  }

  /// Prepare an asset file for native access.
  ///
  /// Copies the asset to a PERMANENT location (app documents directory) so it
  /// persists even when the app is closed. Cache/temp files get cleared by Android.
  static Future<String?> _prepareAssetFile(String soundPath) async {
    // Check if it's already a file system path that exists
    final file = File(soundPath);
    if (file.existsSync()) {
      return soundPath;
    }

    // It's an asset path - need to copy to permanent storage
    final assetPath =
        soundPath.startsWith('assets/') ? soundPath : 'assets/$soundPath';

    // Check cache first (in-memory cache of file paths)
    if (_assetCache.containsKey(assetPath)) {
      final cachedPath = _assetCache[assetPath]!;
      if (File(cachedPath).existsSync()) {
        print('✅ [AdhanService] Using existing file: $cachedPath');
        return cachedPath;
      }
      _assetCache.remove(assetPath);
    }

    // Copy asset to app's documents directory (PERMANENT, not cleared by system)
    try {
      // Use app support directory - permanent storage that survives app restarts
      final appDir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory('${appDir.path}/adhan_sounds');

      // Create directory if it doesn't exist
      if (!soundsDir.existsSync()) {
        await soundsDir.create(recursive: true);
      }

      final fileName = assetPath.split('/').last;
      final permanentFile = File('${soundsDir.path}/$fileName');

      // Check if file already exists in permanent storage
      if (permanentFile.existsSync()) {
        _assetCache[assetPath] = permanentFile.path;
        print('✅ [AdhanService] File already exists: ${permanentFile.path}');
        return permanentFile.path;
      }

      // Copy asset to permanent storage
      final byteData = await rootBundle.load(assetPath);
      await permanentFile.writeAsBytes(byteData.buffer.asUint8List());

      _assetCache[assetPath] = permanentFile.path;
      print(
          '✅ [AdhanService] Asset copied to permanent storage: ${permanentFile.path}');
      return permanentFile.path;
    } catch (e) {
      print('❌ [AdhanService] Error preparing asset: $e');
      return null;
    }
  }
}
