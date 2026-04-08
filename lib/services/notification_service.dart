import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main before this runs.
  debugPrint('[FCM Background] ${message.notification?.title}: ${message.notification?.body}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm   = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  // Android high-importance channel
  static const _channel = AndroidNotificationChannel(
    'smartcam_alerts',
    'SmartCam Alerts',
    description: 'Security camera alerts and notifications',
    importance: Importance.high,
    playSound: true,
  );

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // ── Initialize everything ─────────────────────────────────
  Future<void> initialize() async {
    await _requestPermission();
    await _createAndroidChannel();
    await _initLocalNotifications();
    await _fetchToken();
    _listenForeground();
    _listenTokenRefresh();
    debugPrint('[FCM] Initialized. Token: $_fcmToken');
  }

  // ── Permission ────────────────────────────────────────────
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true, badge: true, sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  // ── Android channel ───────────────────────────────────────
  Future<void> _createAndroidChannel() async {
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  // ── Local notifications init ──────────────────────────────
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // ── FCM token ─────────────────────────────────────────────
  Future<void> _fetchToken() async {
    _fcmToken = await _fcm.getToken();
  }

  void _listenTokenRefresh() {
    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('[FCM] Token refreshed: $token');
    });
  }

  // ── Foreground messages ───────────────────────────────────
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM Foreground] ${message.notification?.title}');
      _showLocalNotification(message);
      _addToAlerts(message);
    });

    // App opened from notification (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM Tap] ${message.notification?.title}');
      Get.toNamed('/alerts');
    });
  }

  // ── Show local notification ───────────────────────────────
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      id: message.hashCode,
      title: notification.title ?? 'SmartCam Alert',
      body: notification.body  ?? 'You have a new alert',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF00E5A0),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // ── Add FCM message to GetX AlertController ───────────────
  void _addToAlerts(RemoteMessage message) {
    // Avoid circular import — use Get.find dynamically
    try {
      final alertCtrl = Get.find(tag: 'alert');
      if (alertCtrl != null) {
        // AlertController.to.addAlertFromFCM(message);
      }
    } catch (_) {}
    // Navigate to alerts screen
    Get.toNamed('/alerts');
  }

  // ── Notification tap handler ──────────────────────────────
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('[Notification Tap] payload: ${response.payload}');
    Get.toNamed('/alerts');
  }

  // ── Show motion alert (triggered from CameraController) ──
  Future<void> showMotionAlert({required String cameraName, required String location}) async {
    await _local.show(
      id: cameraName.hashCode,
      title: 'Motion Detected — $cameraName',
      body: 'Activity detected at $location',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFFFB300),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'motion:$cameraName',
    );
  }

  // ── Check if app was opened from a terminated notification ─
  Future<RemoteMessage?> getInitialMessage() async {
    return await _fcm.getInitialMessage();
  }
}
