import 'package:flutter/material.dart';
import 'package:jamiat/src/interfaces/main_pages/navbar.dart';
import 'package:jamiat/src/interfaces/onboarding/login.dart';
import 'package:jamiat/src/interfaces/onboarding/splash_screen.dart';
import 'package:jamiat/src/interfaces/onboarding/role_selection.dart';
import 'package:jamiat/src/interfaces/onboarding/registration.dart';
import 'package:jamiat/src/interfaces/campaign/campaign_list.dart';
import 'package:jamiat/src/interfaces/campaign/campaign_details.dart';
import 'package:jamiat/src/interfaces/campaign/donation_success.dart';
import 'package:jamiat/src/interfaces/campaign/donations_view.dart';
import 'package:jamiat/src/interfaces/campaign/autopay_view.dart';
import 'package:jamiat/src/interfaces/campaign/autopay_details.dart';
import 'package:jamiat/src/interfaces/campaign/donation_history.dart';
import 'package:jamiat/src/interfaces/campaign/saved_donations.dart';
import 'package:jamiat/src/interfaces/events/events.dart';
import 'package:jamiat/src/interfaces/events/event_details.dart';
import 'package:jamiat/src/interfaces/events/ticket.dart';

enum TransitionType { slideFromBottom, slideFromRight, fade, fadeScale }

PageRouteBuilder<T> createRoute<T>(
  Widget page, {
  TransitionType? transition,
  Duration duration = const Duration(milliseconds: 300),
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: _transitionsBuilderFor(transition),
  );
}

RouteTransitionsBuilder _transitionsBuilderFor(TransitionType? type) {
  switch (type) {
    case TransitionType.slideFromRight:
      return (context, animation, secondaryAnimation, child) {
        // Professional smooth right-to-left slide
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: curved.drive(tween), child: child);
      };

    case TransitionType.fade:
      return (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return FadeTransition(opacity: curved, child: child);
      };

    case TransitionType.fadeScale:
      return (context, animation, secondaryAnimation, child) {
        // subtle scale + fade for a polished material-like entrance
        final fadeAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final scaleTween = Tween<double>(
          begin: 0.98,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));
        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      };

    case TransitionType.slideFromBottom:
    default:
      return (context, animation, secondaryAnimation, child) {
        // Standard bottom-up slide (good for modal-ish pages)
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final tween = Tween(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: curved.drive(tween), child: child);
      };
  }
}

// ignore: unused_element
String _routeString(
  Map<String, dynamic>? args,
  String key, [
  String fallback = '',
]) {
  final value = args?[key];
  if (value == null) return fallback;
  return value.toString();
}

Route<dynamic> generateRoute(RouteSettings? settings) {
  Widget? page;
  TransitionType? transitionToUse;
  Duration transitionDuration = const Duration(milliseconds: 300);

  if (settings?.arguments != null && settings!.arguments is Map) {
    final args = settings.arguments as Map;
    if (args['transition'] is TransitionType) {
      transitionToUse = args['transition'] as TransitionType;
    }
    if (args['duration'] is Duration) {
      transitionDuration = args['duration'] as Duration;
    }
  }

  switch (settings?.name) {
    case 'Splash':
      page = const SplashScreen();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;

    case 'Login':
      page = const LoginScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'RoleSelection':
      page = const RoleSelectionScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'Registration':
      page = const RegistrationScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'DonationList':
      page = const DonationListScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'CampaignDetails':
      final args = settings?.arguments as Map<String, dynamic>?;
      page = CampaignDetailsScreen(
        title: args?['title'] as String? ?? 'Zakat',
        description:
            args?['description'] as String? ??
            'Fulfill your obligatory charity safely and securely.',
        icon: args?['icon'] as IconData? ?? Icons.payments_outlined,
        iconBgColor: args?['iconBgColor'] as Color? ?? const Color(0xFFF0FDF4),
        iconColor: args?['iconColor'] as Color? ?? const Color(0xFF16A34A),
        image: args?['image'] as String?,
        category: args?['category'] as String?,
        raised: args?['raised'] as int?,
        goal: args?['goal'] as int?,
        daysLeft: args?['daysLeft'] as int?,
      );
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'DonationSuccess':
      final args = settings?.arguments as Map<String, dynamic>?;
      page = DonationSuccessScreen(
        isAutopay: args?['isAutopay'] as bool? ?? false,
        amount: args?['amount'] as String? ?? '500',
        period: args?['period'] as String? ?? 'Daily',
        transactionId: args?['transactionId'] as String? ?? 'TR12451BHGF',
        date: args?['date'] as String? ?? '20/06/2026',
        campaignName:
            args?['campaignName'] as String? ?? 'Medical aid for patient',
        message: args?['message'] as String?,
      );
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'DonationsView':
      page = const DonationsViewScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'AutopayView':
      page = const AutopayViewScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'AutopayDetails':
      final args = settings?.arguments as Map<String, dynamic>?;
      page = AutopayDetailsScreen(
        title: args?['title'] as String? ?? 'Zakat',
        description:
            args?['description'] as String? ??
            'Fulfill your obligatory charity safely and securely.',
        icon: args?['icon'] as IconData? ?? Icons.payments_outlined,
        iconBgColor: args?['iconBgColor'] as Color? ?? const Color(0xFFF0FDF4),
        iconColor: args?['iconColor'] as Color? ?? const Color(0xFF16A34A),
        status: args?['status'] as String? ?? 'Auto Pay Cancelled',
        mandateAmount: args?['mandateAmount'] as String? ?? '₹500',
        period: args?['period'] as String? ?? 'Daily',
        startDate: args?['startDate'] as String? ?? '28 Mar,2025',
        endDate: args?['endDate'] as String? ?? '1 Apr,2026',
        history: args?['history'] as List<Map<String, String>>?,
      );
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'DonationHistory':
      page = const DonationHistoryScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'SavedDonations':
      page = const SavedDonationsScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'Events':
      page = const EventsScreen();
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'EventDetails':
      final args = settings?.arguments as Map<String, dynamic>?;
      page = EventDetailsScreen(
        title: args?['title'] as String? ?? 'Event Details',
        category: args?['category'] as String? ?? 'Conference',
        date: args?['date'] as String? ?? '07 Jun, 2026 • 10:45 am - 3:30pm',
        location: args?['location'] as String? ?? 'Ernakulam Town Hall',
        image:
            args?['image'] as String? ?? 'assets/jpgs/campaign_education.jpg',
        isBookmarked: args?['isBookmarked'] as bool? ?? false,
      );
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'EventTicket':
      final args = settings?.arguments as Map<String, dynamic>?;
      page = EventTicketScreen(
        title: args?['title'] as String? ?? 'Annual Jamiat Conference',
        date: args?['date'] as String? ?? '20 Jun 2026',
        venue: args?['venue'] as String? ?? 'Ernakulam Town Hall',
      );
      transitionToUse = TransitionType.slideFromRight;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    case 'navBar':
      page = const NavBar();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 300);
      break;

    default:
      if (settings?.name?.startsWith('/app') == true) {
        return PageRouteBuilder(
          opaque: false,
          settings: settings,
          pageBuilder: (context, _, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
            return const SizedBox();
          },
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      }
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => Scaffold(
          backgroundColor: Colors.grey[100],
          body: Center(child: Text('No path for ${settings?.name}')),
        ),
      );
  }
  return createRoute(
    page,
    transition: transitionToUse,
    duration: transitionDuration,
    settings: settings,
  );
}

extension NavigatorTransitionHelpers on NavigatorState {
  Future<T?> pushWithTransition<T>(
    Widget page, {
    TransitionType transition = TransitionType.slideFromBottom,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return push<T>(
      createRoute(page, transition: transition, duration: duration),
    );
  }
}
