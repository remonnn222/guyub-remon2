import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../../app.dart';

/// Notification Service
/// Handles Firebase Cloud Messaging and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase Messaging and local notifications
  Future<void> initialize() async {
    // Request permission for notifications
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure FCM
    await _configureFCM();

    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Send token to backend if user is authenticated
    if (token != null) {
      await _sendTokenToBackend(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      _sendTokenToBackend(newToken);
    });
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    // Show local notification
    _showLocalNotification(message);
  }

  /// Handle background messages
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    debugPrint('Background message: ${message.notification?.title}');
    // Background messages are handled automatically by FCM
  }

  /// Handle messages when app is opened from terminated state
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.notification?.title}');
    _navigateBasedOnNotification(message);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final message = RemoteMessage.fromMap(jsonDecode(payload));
        _navigateBasedOnNotification(message);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'guyub_channel',
      'Guyub Notifications',
      channelDescription: 'Notifications for Guyub app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.toMap()),
    );
  }

  /// Navigate based on notification type
  void _navigateBasedOnNotification(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    if (type == null) return;

    // Get the root navigator key from app.dart
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('Navigation skipped - no context');
      return;
    }

    switch (type) {
      case 'event_new':
      case 'event_approved':
      case 'event_rejected':
        context.go('/events');
        break;
      case 'family_join':
      case 'family_invite':
        context.go('/family');
        break;
      case 'system':
        context.go('/profile');
        break;
      default:
        context.go('/');
    }
  }

  /// Send FCM token to backend
  /// Send FCM token to backend (handled by auth_provider on login)
  Future<void> _sendTokenToBackend(String token) async {
    debugPrint(
      'FCM token received (auth_provider handles backend sync): $token',
    );
  }
}
