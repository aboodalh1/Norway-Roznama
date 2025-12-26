import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

const _channelId = 'adhan_media';
const _channelName = 'Adhan Playback';
const _channelDescription = 'Adhan playback controls';
const _defaultMaxDuration = Duration(minutes: 5);

AdhanAudioHandler? _cachedHandler;

/// Ensures a single audio handler instance is available in the current isolate.
Future<AdhanAudioHandler> initAdhanAudioHandler() async {
  // #region agent log
  try {
    final logFile = File(
        r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
    await logFile.writeAsString(
      '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"adhan_audio_handler.dart:14","message":"initAdhanAudioHandler entry","data":{"cachedHandler":_cachedHandler != null},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
      mode: FileMode.append,
    );
  } catch (_) {}
  // #endregion

  print('🔧 [initAdhanAudioHandler] Starting initialization...');

  if (_cachedHandler != null) {
    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"adhan_audio_handler.dart:20","message":"Returning cached handler","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion
    print('✅ [initAdhanAudioHandler] Returning cached handler');
    return _cachedHandler!;
  }

  // Initialize just_audio_background for background audio support
  // #region agent log
  try {
    final logFile = File(
        r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
    await logFile.writeAsString(
      '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"B","location":"adhan_audio_handler.dart:35","message":"Initializing JustAudioBackground","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
      mode: FileMode.append,
    );
  } catch (_) {}
  // #endregion

  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: _channelId,
      androidNotificationChannelName: _channelName,
      androidNotificationChannelDescription: _channelDescription,
    );
    print('✅ [initAdhanAudioHandler] JustAudioBackground initialized');
  } catch (e) {
    print(
        '⚠️ [initAdhanAudioHandler] JustAudioBackground init failed (may already be initialized): $e');
    // Continue anyway - it might already be initialized
  }

  // #region agent log
  try {
    final logFile = File(
        r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
    await logFile.writeAsString(
      '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"adhan_audio_handler.dart:50","message":"Before AudioService.init","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
      mode: FileMode.append,
    );
  } catch (_) {}
  // #endregion

  try {
    print('🔧 [initAdhanAudioHandler] Initializing AudioService...');
    _cachedHandler = await AudioService.init(
      builder: () => AdhanAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: _channelId,
        androidNotificationChannelName: _channelName,
        androidNotificationChannelDescription: _channelDescription,
        androidStopForegroundOnPause: true,
        androidNotificationOngoing: true, // keep notification while playing
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );
    print('✅ [initAdhanAudioHandler] AudioService initialized successfully');

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"adhan_audio_handler.dart:65","message":"AudioService.init success","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"adhan_audio_handler.dart:45","message":"AudioService.init success","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    return _cachedHandler!;
  } catch (e, stackTrace) {
    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"init","hypothesisId":"A","location":"adhan_audio_handler.dart:52","message":"AudioService.init error","data":{"error":e.toString(),"stackTrace":stackTrace.toString()},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion
    rethrow;
  }
}

class AdhanAudioHandler extends BaseAudioHandler with SeekHandler {
  AdhanAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        stop();
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();
  Timer? _maxDurationTimer;

  /// Start Adhan playback with a media-style notification.
  Future<void> startAdhan({
    required String soundPath,
    int id = 1,
    String title = 'Adhan',
    String body = 'Prayer time',
    Duration maxDuration = _defaultMaxDuration,
    double volume = 1.0,
  }) async {
    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"adhan-start","hypothesisId":"C","location":"adhan_audio_handler.dart:45","message":"startAdhan called","data":{"soundPath":soundPath,"id":id,"title":title},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    print(
        '🔊 [AdhanAudioHandler] Starting Adhan playback: $soundPath, ID: $id');

    _maxDurationTimer?.cancel();
    await stop(); // ensure clean start

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"adhan-start","hypothesisId":"C","location":"adhan_audio_handler.dart:55","message":"Creating media item","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    final media = MediaItem(
      id: 'adhan_$id',
      title: title,
      album: 'Prayer',
      artist: body,
      extras: {'alarmId': id},
    );
    mediaItem.add(media);

    // #region agent log
    try {
      final logFile = File(
          r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
      await logFile.writeAsString(
        '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"adhan-start","hypothesisId":"C","location":"adhan_audio_handler.dart:70","message":"Setting audio source","data":{"soundPath":soundPath},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
        mode: FileMode.append,
      );
    } catch (_) {}
    // #endregion

    try {
      await _player.setAudioSource(AudioSource.asset(soundPath));
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(volume);

      // #region agent log
      try {
        final logFile = File(
            r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
        await logFile.writeAsString(
          '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"adhan-start","hypothesisId":"C","location":"adhan_audio_handler.dart:80","message":"Starting playback","data":{},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
          mode: FileMode.append,
        );
      } catch (_) {}
      // #endregion

      await _player.play();

      print('✅ [AdhanAudioHandler] Playback started successfully');

      // #region agent log
      try {
        final logFile = File(
            r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
        await logFile.writeAsString(
          '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"adhan-start","hypothesisId":"C","location":"adhan_audio_handler.dart:90","message":"Playback started - setting max duration timer","data":{"maxDurationSeconds":maxDuration.inSeconds},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
          mode: FileMode.append,
        );
      } catch (_) {}
      // #endregion

      // Safety valve to prevent runaway audio.
      _maxDurationTimer = Timer(maxDuration, () {
        print('⏰ [AdhanAudioHandler] Max duration reached, stopping');
        stop();
      });
    } catch (e, stackTrace) {
      print('❌ [AdhanAudioHandler] Error starting playback: $e');
      print('Stack trace: $stackTrace');

      // #region agent log
      try {
        final logFile = File(
            r'c:\Users\hp\Desktop\git_repos\flutter\Norway-Roznama\.cursor\debug.log');
        await logFile.writeAsString(
          '${logFile.existsSync() ? await logFile.readAsString() : ""}{"sessionId":"debug-session","runId":"adhan-start","hypothesisId":"C","location":"adhan_audio_handler.dart:105","message":"Error in startAdhan","data":{"error":e.toString(),"stackTrace":stackTrace.toString()},"timestamp":${DateTime.now().millisecondsSinceEpoch}}\n',
          mode: FileMode.append,
        );
      } catch (_) {}
      // #endregion

      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    await _player.stop();
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [MediaControl.stop],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
    return super.stop();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    final processingState = _mapProcessingState(_player.processingState);
    final playing = _player.playing;

    return PlaybackState(
      controls: const [MediaControl.stop],
      androidCompactActionIndices: const [0],
      processingState: processingState,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: null,
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}

/// Facade used across the app/alarm/background entry points.
class AdhanAudioController {
  static Future<void> playAdhan({
    required String soundPath,
    int id = 1,
    String title = 'Adhan',
    String body = 'Prayer time',
    Duration maxDuration = _defaultMaxDuration,
    double volume = 1.0,
  }) async {
    final handler = await initAdhanAudioHandler();
    await handler.startAdhan(
      soundPath: soundPath,
      id: id,
      title: title,
      body: body,
      maxDuration: maxDuration,
      volume: volume,
    );
  }

  static Future<void> stopAdhan() async {
    final handler = await initAdhanAudioHandler();
    await handler.stop();
  }
}
