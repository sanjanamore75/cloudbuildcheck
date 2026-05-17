import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Entry-point for the foreground service isolate.
/// Must be a top-level function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
void ringtoneTaskEntryPoint() {
  FlutterForegroundTask.setTaskHandler(RingtoneTaskHandler());
}

/// Plays incoming.mp3 on a loop inside an Android foreground service.
/// The service keeps running even when the host app is killed, so the
/// ringtone continues until the user accepts or declines the call.
class RingtoneTaskHandler extends TaskHandler {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('🔔 RingtoneTaskHandler: starting ringtone');
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('ringtone/incoming.mp3'));
  }

  /// Called at the interval set in [FlutterForegroundTask.init] — not used.
  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('🔕 RingtoneTaskHandler: stopping ringtone');
    await _player.stop();
    await _player.dispose();
  }

  /// Receives messages sent via [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    if (data == 'stop') {
      FlutterForegroundTask.stopService();
    }
  }
}
