import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM: ${message.notification?.title}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _local  = FlutterLocalNotificationsPlugin();

  bool get _isFirebaseSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows;
    } catch (_) {
      return false;
    }
  }

  FirebaseMessaging? get _fcm {
    if (!_isFirebaseSupported) return null;
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }

  static const _channelId   = 'ambulink_bookings';
  static const _channelName = 'Booking Notifications';

  Future<void> initialize() async {
    // Request permission
    if (_isFirebaseSupported) {
      await _fcm?.requestPermission(alert: true, badge: true, sound: true);

      // Background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // Local notification channel (Android)
    if (!kIsWeb && Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        _channelId, _channelName,
        description:  'AmbuLink booking and emergency alerts',
        importance:   Importance.max,
        playSound:    true,
        enableVibration: true,
      );

      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }

    // Init local notifications
    bool isLinux = false;
    if (!kIsWeb) {
      try { isLinux = Platform.isLinux; } catch (_) {}
    }

    final initSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      linux: isLinux 
          ? const LinuxInitializationSettings(defaultActionName: 'Open notification')
          : null,
    );
    
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Foreground messages
    if (_isFirebaseSupported) {
      FirebaseMessaging.onMessage.listen(_showLocalNotification);

      // Opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((msg) {
        debugPrint('Notification opened: ${msg.data}');
      });
    }
  }

  Future<String?> getToken() async {
    if (!_isFirebaseSupported) return null;
    return _fcm?.getToken();
  }

  void _showLocalNotification(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;
    _local.show(
      notif.hashCode,
      notif.title,
      notif.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, _channelName,
          importance: Importance.max,
          priority:   Priority.high,
          icon:       '@mipmap/ic_launcher',
          color:      Color(0xFFDC2626),
        ),
      ),
      payload: message.data['booking_id'],
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Tapped notification payload: ${response.payload}');
    // Navigation handled in main app via GlobalKey<NavigatorState>
  }
}
