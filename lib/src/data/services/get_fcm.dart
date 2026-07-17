import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:jamiat/src/data/services/secure_storage_service.dart';
import 'package:jamiat/src/data/apis/user_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> handleNotificationPermissions(
  BuildContext context,
  WidgetRef ref,
) async {
  // Handle platform-specific FCM permissions
  if (Platform.isIOS) {
    await _handleIOSPermissions(context, ref);
  } else {
    await _handleAndroidPermissions(context, ref);
  }
}

Future<void> _handleIOSPermissions(BuildContext context, WidgetRef ref) async {
  final settings = await FirebaseMessaging.instance.getNotificationSettings();
  if (!context.mounted) return;

  if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    final resourceSettings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (!context.mounted) return;
    if (resourceSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      await _setupFCM(context, ref);
    } else {
      debugPrint('User declined notification permission');
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    if (context.mounted) {
      _showNotificationPermissionDialog(context);
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    await _setupFCM(context, ref);
  }
}

Future<void> _handleAndroidPermissions(
  BuildContext context,
  WidgetRef ref,
) async {
  final status = await Permission.notification.status;
  if (!context.mounted) return;

  if (status.isGranted) {
    await _setupFCM(context, ref);
  } else if (status.isPermanentlyDenied) {
    if (context.mounted) {
      _showNotificationPermissionDialog(context);
    }
  } else {
    final result = await Permission.notification.request();
    if (!context.mounted) return;
    if (result.isGranted) {
      await _setupFCM(context, ref);
    }
  }
}

Future<void> _setupFCM(BuildContext context, WidgetRef ref) async {
  try {
    final messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      debugPrint("APNs Token: $apnsToken");
    }

    String? token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      final secureStorage = ref.read(secureStorageServiceProvider);
      // Save locally
      await secureStorage.saveFcmToken(token);
      debugPrint("FCM Token: $token");

      // Check if user is logged in (has an auth token)
      final authToken = await secureStorage.getAuthToken();
      if (authToken != null && authToken.isNotEmpty) {
        // If logged in, upload the FCM token to the backend
        final userApi = ref.read(userApiProvider);
        final response = await userApi.updateFcmToken(token);
        if (response.success) {
          debugPrint("FCM Token uploaded to backend successfully.");
        } else {
          debugPrint(
            "Failed to upload FCM token to backend: ${response.message}",
          );
        }
      }
    }
  } catch (e) {
    debugPrint('Error setting up FCM: $e');
  }
}

Future<void> getFcmToken(BuildContext context, WidgetRef ref) async {
  await handleNotificationPermissions(context, ref);
}

void _showNotificationPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Stay Updated"),
      content: const Text(
        "Enable notifications to receive important updates and stay connected.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Not Now"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: const Text("Open Settings"),
        ),
      ],
    ),
  );
}
