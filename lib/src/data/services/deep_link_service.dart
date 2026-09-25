import 'package:flutter/material.dart';
import 'package:jamiat/src/data/config/app_config.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

/// Parses and routes campaign deep links from share landing pages.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  static final RegExp _objectId = RegExp(r'^[a-fA-F0-9]{24}$');

  String? _pendingCampaignId;
  bool _ready = false;

  String? get pendingCampaignId => _pendingCampaignId;

  /// Call once the root navigator exists and auth routing has settled.
  void markReady() {
    _ready = true;
    consumePendingCampaignLink();
  }

  void resetReady() {
    _ready = false;
  }

  void handleUri(Uri? uri) {
    if (uri == null) return;
    final campaignId = extractCampaignId(uri);
    if (campaignId == null || campaignId.isEmpty) return;
    debugPrint('DeepLinkService: campaign=$campaignId from $uri');
    openCampaign(campaignId);
  }

  /// Flutter may pass the deep link as [MaterialApp]'s initial / pushed route
  /// name (e.g. `jamiatconnect://campaign/<id>` or `/<id>`).
  void handlePlatformInitialRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty || routeName == '/') return;
    // Ignore normal named routes from our own navigator.
    const known = {
      'Splash',
      'Login',
      'RoleSelection',
      'Registration',
      'navBar',
      'CampaignDetails',
    };
    if (known.contains(routeName)) return;

    final uri = Uri.tryParse(routeName);
    if (uri != null && (uri.hasScheme || routeName.startsWith('/'))) {
      handleUri(uri);
      return;
    }
    // Path-only fallback: campaign/<id>
    handleUri(Uri.parse('jamiatconnect://$routeName'));
  }

  /// True when [routeName] looks like a platform deep-link route (not an app
  /// named route). Used by the router to avoid the "No path" screen.
  static bool looksLikeDeepLinkRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty || routeName == '/') {
      return false;
    }
    if (routeName.contains('://')) return true;
    if (routeName.contains('campaign') || routeName.contains('share')) {
      return true;
    }
    // Flutter strips scheme+host and pushes path only: `/<objectId>`
    final segments =
        routeName.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length == 1 && _objectId.hasMatch(segments.first)) {
      return true;
    }
    return false;
  }

  static String? extractCampaignId(Uri uri) {
    // jamiatconnect://campaign/<id>
    if (uri.scheme == AppConfig.appDeepLinkScheme ||
        uri.scheme == 'jamiatconnect') {
      if (uri.host == 'campaign' && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
      if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'campaign') {
        return uri.pathSegments[1];
      }
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    // /campaign/<id>
    if (segments.length >= 2 && segments.first == 'campaign') {
      return segments[1];
    }
    // …/share/campaign/<id>  (with or without /api/v1 prefix)
    for (var i = 0; i + 2 < segments.length; i++) {
      if (segments[i] == 'share' && segments[i + 1] == 'campaign') {
        final id = segments[i + 2];
        if (id.isNotEmpty) return id;
      }
    }

    // Flutter deep-link path-only: /<objectId>
    if (segments.length == 1 && _objectId.hasMatch(segments.first)) {
      return segments.first;
    }

    final queryId = uri.queryParameters['campaignId'] ??
        uri.queryParameters['campaign_id'] ??
        uri.queryParameters['id'];
    if (queryId != null && queryId.isNotEmpty) return queryId;

    return null;
  }

  void openCampaign(String campaignId) {
    final nav = NavigationService.navigatorKey.currentState;
    if (!_ready || nav == null) {
      _pendingCampaignId = campaignId;
      return;
    }

    _pendingCampaignId = null;
    NavigationService().pushNamed(
      'CampaignDetails',
      arguments: {'campaignId': campaignId},
    );
  }

  void consumePendingCampaignLink() {
    final id = _pendingCampaignId;
    if (id == null || id.isEmpty) return;
    openCampaign(id);
  }
}
