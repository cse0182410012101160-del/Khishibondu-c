import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// One-shot Firebase bootstrap for Agro-Bridge.
///
/// Safe across all platforms (Web, Android, iOS).
/// Gracefully falls back when credentials or web options are unconfigured,
/// preventing any blocking startup crashes.
class FirebaseInitializer {
  FirebaseInitializer._();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      if (kIsWeb) {
        // Firebase on Web requires explicit FirebaseOptions
        try {
          await Firebase.initializeApp(
            options: const FirebaseOptions(
              apiKey: "AIzaSyAgroBridgeDemoKeyWebOnly12345",
              authDomain: "agro-bridge-bd.firebaseapp.com",
              projectId: "agro-bridge-bd",
              storageBucket: "agro-bridge-bd.appspot.com",
              messagingSenderId: "123456789012",
              appId: "1:123456789012:web:abcdef123456",
            ),
          );
        } catch (e) {
          debugPrint('⚠️ [Firebase Web] Default web options bypassed: $e');
        }
      } else {
        try {
          await Firebase.initializeApp();
        } catch (e) {
          debugPrint('⚠️ [Firebase Mobile] Default init bypassed: $e');
        }
      }

      // Crashlytics: Supported only on Mobile platforms (Android/iOS)
      if (!kIsWeb) {
        try {
          if (!kDebugMode) {
            await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
          } else {
            await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
          }
        } catch (e) {
          debugPrint('⚠️ [Crashlytics] Bypassed: $e');
        }
      }

      // FCM: Guard with try-catch so Web/emulator without VAPID doesn't crash
      if (!kIsWeb) {
        try {
          await FirebaseMessaging.instance.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );

          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (kDebugMode && fcmToken != null) {
            debugPrint('🔥 FCM token: $fcmToken');
          }

          FirebaseMessaging.onMessage.listen(_onForegroundMessage);
          FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
          FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
        } catch (e) {
          debugPrint('⚠️ [FCM] Bypassed push notification init: $e');
        }
      }

      _initialized = true;
    } catch (e) {
      debugPrint('⚠️ [FirebaseInitializer] Non-fatal init warning: $e');
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    debugPrint('📩 FCM foreground message: ${message.notification?.title}');
  }

  static void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('📬 FCM opened from notification: ${message.messageId}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    debugPrint('🌙 FCM background message: ${message.messageId}');
  }
}
