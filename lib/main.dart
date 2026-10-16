import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jamiat/firebase_options.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/providers/screen_data_providers.dart';
import 'package:jamiat/src/data/router/route.dart' as router;
import 'package:jamiat/src/data/services/deep_link_service.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

// ── Local notification channel (Android) ─────────────────────────────────────
const _kChannelId = 'jamiat_push';
const _kChannelName = 'Jamiat Notifications';
const _kChannelDesc = 'General Jamiat push notifications';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

/// Background message handler — MUST be a top-level function.
/// Called when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Firebase is already initialised by the time this runs, but dotenv is not.
  // Nothing to do here: the FCM SDK delivers the notification to the system
  // tray automatically. We just need the handler registered.
  debugPrint(
    '[FCM background] ${message.notification?.title} — ${message.data}',
  );
}

/// Navigate to the correct screen from an FCM data payload.
void _handleMessageNavigation(Map<String, dynamic> data) {
  final screen = data['screen'] as String?;
  final id = data['id'] as String?;

  switch (screen) {
    case 'campaign':
      if (id != null) {
        NavigationService().pushNamed(
          'CampaignDetails',
          arguments: {'campaignId': id},
        );
      }
    case 'event':
      if (id != null) {
        NavigationService().pushNamed(
          'EventDetails',
          arguments: {'eventId': id},
        );
      }
    case 'autopay':
      if (id != null) {
        NavigationService().pushNamed('AutopayDetails', arguments: id);
      }
    default:
      NavigationService().pushNamed('Notifications');
  }
}

/// Initialise the local notification plugin and create the Android channel.
Future<void> _initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwinSettings = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: darwinSettings,
  );

  await _localNotifications.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      // User tapped the local notification banner while the app was in the
      // foreground. Parse the payload we set in _showForegroundNotification.
      final payload = details.payload ?? '';
      // Use indexOf to safely split only at the FIRST colon — ObjectIds never
      // contain colons but be defensive for future screen values.
      final sep = payload.indexOf(':');
      final screen = sep >= 0 ? payload.substring(0, sep) : payload;
      final id = sep >= 0 ? payload.substring(sep + 1) : null;
      _handleMessageNavigation({
        'screen': screen,
        'id': id?.isNotEmpty == true ? id : null,
      });
    },
  );

  // Create the Android notification channel (no-op on iOS).
  const channel = AndroidNotificationChannel(
    _kChannelId,
    _kChannelName,
    description: _kChannelDesc,
    importance: Importance.high,
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

/// Show a local notification banner when a push arrives while the app is in
/// the foreground (FCM does NOT show a system banner in that case).
Future<void> _showForegroundNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  final screen = message.data['screen'] ?? '';
  final id = message.data['id'] ?? '';
  final payload = '$screen:$id';

  await _localNotifications.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: _kChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: payload,
  );
}

// ── App entry point ───────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register the background handler before any other FCM setup.
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

  await dotenv.load(fileName: '.env');
  await _initLocalNotifications();

  runApp(const ProviderScope(child: MyApp()));
}

// ── Root widget ───────────────────────────────────────────────────────────────

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _initFcmHandlers();
  }

  // ── Deep links ─────────────────────────────────────────────────────────────

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();
    try {
      final initial = await appLinks.getInitialLink();
      DeepLinkService.instance.handleUri(initial);
    } catch (e, st) {
      debugPrint('Initial deep link failed: $e\n$st');
    }

    _linkSub = appLinks.uriLinkStream.listen(
      DeepLinkService.instance.handleUri,
      onError: (Object e) => debugPrint('Deep link stream error: $e'),
    );
  }

  // ── FCM runtime handlers ───────────────────────────────────────────────────

  void _initFcmHandlers() {
    // 1) App was killed — user tapped the notification that launched the app.
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // The navigator is not ready yet; delay until after first frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleMessageNavigation(message.data);
        });
      }
    });

    // 2) App was in the background — user tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessageNavigation(message.data);
    });

    // 3) App is in the foreground — show a local banner ourselves.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
        '[FCM foreground] ${message.notification?.title} — ${message.data}',
      );
      _showForegroundNotification(message);
    });

    // 4) Token refresh — re-upload to backend and re-subscribe to topic.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed: $newToken');

      // Re-subscribe to broadcast topic (defence-in-depth).
      FirebaseMessaging.instance
          .subscribeToTopic('push_notification')
          .catchError(
            (Object e) => debugPrint('[FCM] Topic re-subscribe error: $e'),
          );

      // Re-upload the new token to the backend so targeted notifications
      // (autopay, event-start) continue to reach this device.
      try {
        final storage = FlutterSecureStorage();
        final authToken = await storage.read(key: 'auth_token');
        final baseUrl = dotenv.env['API_URL'] ?? '';
        if (authToken != null && authToken.isNotEmpty && baseUrl.isNotEmpty) {
          await http.put(
            Uri.parse('$baseUrl/user/fcm'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'fcm': newToken}),
          );
          debugPrint('[FCM] Token re-uploaded to backend.');
        }
      } catch (e) {
        debugPrint('[FCM] Token re-upload error: $e');
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      onGenerateRoute: router.generateRoute,
      // Platform deep links (jamiatconnect://…) override [initialRoute]. Always
      // boot via Splash and let DeepLinkService open the campaign afterward.
      onGenerateInitialRoutes: (String initialRoute) {
        DeepLinkService.instance.handlePlatformInitialRoute(initialRoute);
        return [router.generateRoute(const RouteSettings(name: 'Splash'))];
      },
      initialRoute: 'Splash',
      title: 'Jamiat Connect',
      locale: const Locale('en', 'IN'),
      supportedLocales: const [
        Locale('en', 'IN'),
        Locale('en', 'GB'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
        ),
        fontFamily: kFontFamily,
        useMaterial3: true,
      ),
      builder: (context, child) {
        return ScreenSizeScope(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
