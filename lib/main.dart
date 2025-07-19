import 'package:dynamic_island/pages/dynamic_island.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DynamicIslandBridge.startService(); // ✅ Start service early
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DynamicIsland(),
    );
  }
}

class DynamicIslandBridge {
  static const MethodChannel _methodChannel =
      MethodChannel('com.example.dynamic_island/dynamic_island');

  static const EventChannel _eventChannel =
      EventChannel('com.example.dynamic_island/notifications');

  /// Start the Android foreground service
  static Future<void> startService() async {
    try {
      await _methodChannel.invokeMethod('startService');
    } catch (e) {
      debugPrint('Error starting service: $e');
    }
  }

  static Future<void> openNotificationAccessSettings() async {
    try {
      await _methodChannel.invokeMethod('openNotificationSettings');
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
    }
  }

  /// Update text on the Dynamic Island notification
  static Future<void> updateText(String text) async {
    try {
      await _methodChannel.invokeMethod('updateText', {'text': text});
    } catch (e) {
      debugPrint('Error updating text: $e');
    }
  }

  /// Receive data from Android through EventChannel (e.g., notifications)
  static Stream<dynamic> get notificationStream =>
      _eventChannel.receiveBroadcastStream();
}

class NotificationActionInvoker {
  static const MethodChannel _actionChannel =
      MethodChannel('com.example.dynamic_island/action');

  static Future<bool> invokeNotificationAction({
    required String packageName,
    required String notificationKey,
    required int actionIndex,
  }) async {
    try {
      final bool result = await _actionChannel.invokeMethod(
        'invokeNotificationAction',
        {
          'packageName': packageName,
          'notificationKey': notificationKey,
          'actionIndex': actionIndex,
        },
      );
      return result;
    } catch (e) {
      return false;
    }
  }
}
