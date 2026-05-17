import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:chating/services/ringtone_task_handler.dart';

/// Manages the Android foreground service that loops incoming.mp3.
///
/// Call [RingtoneService.start] from anywhere — including the FCM
/// background isolate (app killed). Call [RingtoneService.stop] when
/// the user accepts or declines the call.
class RingtoneService {
  RingtoneService._();

  static const int _serviceId = 9001;

  // ── Configuration ──────────────────────────────────────────────────────────

  static void _configure() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'ringtone_service_channel',
        channelName: 'Incoming Call Ringtone',
        channelDescription: 'Keeps the ringtone playing for incoming calls',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        // Hide the foreground-service notification — the call notification
        // (posted by NotificationService) is already visible to the user.
        visibility: NotificationVisibility.VISIBILITY_SECRET,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        // No repeat events needed — audio loops on its own via audioplayers.
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Starts the foreground service and begins looping incoming.mp3.
  /// Safe to call from the FCM background isolate (app killed).
  static Future<void> start({
    String callerName = 'Incoming Call',
  }) async {
    _configure();

    final result = await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      notificationTitle: callerName,
      notificationText: 'Tap to open',
      notificationIcon: null,
      callback: ringtoneTaskEntryPoint,
    );

    if (result is ServiceRequestSuccess) {
      print('✅ RingtoneService: foreground service started');
    } else if (result is ServiceRequestFailure) {
      print('⚠️ RingtoneService: could not start foreground service');
    }
  }

  /// Stops the foreground service and the ringtone immediately.
  static Future<void> stop() async {
    await FlutterForegroundTask.stopService();
    print('🔕 RingtoneService: foreground service stopped');
  }
}
