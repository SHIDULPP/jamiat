import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: MyApp()));
}

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
  }

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

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

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
        return [
          router.generateRoute(const RouteSettings(name: 'Splash')),
        ];
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
