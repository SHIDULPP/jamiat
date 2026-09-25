import 'package:flutter/material.dart';
import 'package:jamiat/src/data/config/app_config.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

/// Parses and routes campaign deep links from share landing pages.
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  static final RegExp _objectId = RegExp(r'^[a-fA-F0-9]{24}$');

  /// Same link often arrives from getInitialLink + uriLinkStream + platform
  /// route within a short window; ignore repeats so screens aren't stacked twice.
  static const _dedupeWindow = Duration(seconds: 4);

  static const _listDedupeKey = '__campaign_list__';
  static const _donateDedupeKey = '__donate__';

  /// Donate tab in [NavBar] (`DonatePage`).
  static const donateTabIndex = 1;

  String? _pendingCampaignId;
  bool _pendingCampaignList = false;
  int? _pendingNavTab;
  String? _lastOpenedKey;
  DateTime? _lastOpenedAt;
  bool _ready = false;

  /// Set by [NavBar] so deep links can switch bottom tabs.
  void Function(int index)? onSelectNavTab;

  String? get pendingCampaignId => _pendingCampaignId;

  /// Call once the root navigator exists and auth routing has settled.
  void markReady() {
    _ready = true;
    consumePending();
  }

  void resetReady() {
    _ready = false;
  }

  void handleUri(Uri? uri) {
    if (uri == null) return;

    if (isDonateLink(uri)) {
      debugPrint('DeepLinkService: donate tab from $uri');
      openDonate();
      return;
    }

    if (isCampaignListLink(uri)) {
      debugPrint('DeepLinkService: campaign list from $uri');
      openCampaignList();
      return;
    }

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
      'DonationList',
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
    final lower = routeName.toLowerCase();
    if (lower.contains('campaign') ||
        lower.contains('share') ||
        lower.contains('donate')) {
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

  /// `jamiatconnect://donate` or `…/share/donate`
  static bool isDonateLink(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host == 'donate') return true;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length == 1 && segments.first.toLowerCase() == 'donate') {
      return true;
    }
    // …/share/donate
    for (var i = 0; i + 1 < segments.length; i++) {
      if (segments[i].toLowerCase() == 'share' &&
          segments[i + 1].toLowerCase() == 'donate') {
        return true;
      }
    }
    return false;
  }

  /// `jamiatconnect://campaign/list`, `jamiatconnect://campaigns`, `/campaign/list`
  static bool isCampaignListLink(Uri uri) {
    final schemeOk = uri.scheme == AppConfig.appDeepLinkScheme ||
        uri.scheme == 'jamiatconnect' ||
        uri.scheme == 'https' ||
        uri.scheme == 'http' ||
        !uri.hasScheme;

    if (!schemeOk && uri.hasScheme) return false;

    if (uri.host == 'campaigns' || uri.host == 'campaign-list') {
      return true;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    if (uri.host == 'campaign') {
      if (segments.isEmpty) return false;
      final first = segments.first.toLowerCase();
      return first == 'list' || first == 'lists';
    }

    if (segments.length >= 2 &&
        segments[0].toLowerCase() == 'campaign' &&
        (segments[1].toLowerCase() == 'list' ||
            segments[1].toLowerCase() == 'lists')) {
      return true;
    }
    if (segments.length == 1 &&
        (segments.first.toLowerCase() == 'campaigns' ||
            segments.first.toLowerCase() == 'campaign-list')) {
      return true;
    }
    return false;
  }

  static String? extractCampaignId(Uri uri) {
    // jamiatconnect://campaign/<id>  (skip reserved "list")
    if (uri.scheme == AppConfig.appDeepLinkScheme ||
        uri.scheme == 'jamiatconnect') {
      if (uri.host == 'campaign' && uri.pathSegments.isNotEmpty) {
        final id = uri.pathSegments.first;
        if (id.toLowerCase() == 'list' || id.toLowerCase() == 'lists') {
          return null;
        }
        return id;
      }
      if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'campaign') {
        final id = uri.pathSegments[1];
        if (id.toLowerCase() == 'list' || id.toLowerCase() == 'lists') {
          return null;
        }
        return id;
      }
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    // /campaign/<id>
    if (segments.length >= 2 && segments.first == 'campaign') {
      final id = segments[1];
      if (id.toLowerCase() == 'list' || id.toLowerCase() == 'lists') {
        return null;
      }
      return id;
    }
    // …/share/campaign/<id>  (with or without /api/v1 prefix)
    for (var i = 0; i + 2 < segments.length; i++) {
      if (segments[i] == 'share' && segments[i + 1] == 'campaign') {
        final id = segments[i + 2];
        if (id.isNotEmpty &&
            id.toLowerCase() != 'list' &&
            id.toLowerCase() != 'lists') {
          return id;
        }
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

  bool _isDuplicate(String key) {
    if (_lastOpenedKey != key || _lastOpenedAt == null) return false;
    return DateTime.now().difference(_lastOpenedAt!) < _dedupeWindow;
  }

  void _markOpened(String key) {
    _lastOpenedKey = key;
    _lastOpenedAt = DateTime.now();
  }

  void _clearPendingTargets() {
    _pendingCampaignId = null;
    _pendingCampaignList = false;
    _pendingNavTab = null;
  }

  void _popToNavBar() {
    final nav = NavigationService.navigatorKey.currentState;
    if (nav == null) return;
    nav.popUntil(
      (route) => route.isFirst || route.settings.name == 'navBar',
    );
  }

  void _selectNavTab(int index) {
    final switcher = onSelectNavTab;
    if (switcher != null) {
      switcher(index);
      return;
    }
    _pendingNavTab = index;
  }

  /// Applies a queued tab switch once [NavBar] has registered [onSelectNavTab].
  void consumePendingNavTab() {
    final tab = _pendingNavTab;
    if (tab == null) return;
    final switcher = onSelectNavTab;
    if (switcher == null) return;
    _pendingNavTab = null;
    switcher(tab);
  }

  void openDonate() {
    if (_isDuplicate(_donateDedupeKey)) {
      debugPrint('DeepLinkService: skip duplicate donate');
      _pendingNavTab = null;
      return;
    }

    final nav = NavigationService.navigatorKey.currentState;
    if (!_ready || nav == null) {
      _clearPendingTargets();
      _pendingNavTab = donateTabIndex;
      return;
    }

    _clearPendingTargets();
    _markOpened(_donateDedupeKey);
    _popToNavBar();
    _selectNavTab(donateTabIndex);
  }

  void openCampaignList() {
    if (_isDuplicate(_listDedupeKey)) {
      debugPrint('DeepLinkService: skip duplicate campaign list');
      _pendingCampaignList = false;
      return;
    }

    final nav = NavigationService.navigatorKey.currentState;
    if (!_ready || nav == null) {
      _clearPendingTargets();
      _pendingCampaignList = true;
      return;
    }

    _clearPendingTargets();
    _markOpened(_listDedupeKey);
    NavigationService().pushNamed('DonationList');
  }

  void openCampaign(String campaignId) {
    if (_isDuplicate(campaignId)) {
      debugPrint('DeepLinkService: skip duplicate $campaignId');
      _pendingCampaignId = null;
      return;
    }

    final nav = NavigationService.navigatorKey.currentState;
    if (!_ready || nav == null) {
      _clearPendingTargets();
      _pendingCampaignId = campaignId;
      return;
    }

    _clearPendingTargets();
    _markOpened(campaignId);
    NavigationService().pushNamed(
      'CampaignDetails',
      arguments: {'campaignId': campaignId},
    );
  }

  void consumePending() {
    if (_pendingNavTab != null) {
      openDonate();
      return;
    }
    if (_pendingCampaignList) {
      openCampaignList();
      return;
    }
    final id = _pendingCampaignId;
    if (id == null || id.isEmpty) return;
    openCampaign(id);
  }
}
