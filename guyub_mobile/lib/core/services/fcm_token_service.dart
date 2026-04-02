import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../di/injection_container.dart';

/// FCM Token Service
/// Manages FCM token storage and sending to backend
class FcmTokenService {
  static final FcmTokenService _instance = FcmTokenService._internal();
  factory FcmTokenService() => _instance;
  FcmTokenService._internal();

  final Dio _dio = sl<Dio>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Send FCM token to backend
  Future<void> sendTokenToBackend(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) return;

      final response = await _dio.post(
        'https://api.guyub.id/api/v1/auth/fcm-token',
        data: {'user_id': userId, 'fcm_token': token},
      );

      if (response.statusCode == 200) {
        print('FCM token sent successfully');
      }
    } catch (e) {
      print('Error sending FCM token: $e');
      rethrow;
    }
  }
}
