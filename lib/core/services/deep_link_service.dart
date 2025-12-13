import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscriptions;

  Function(String containerId)? onContainerLink;

  Future<void> init() async {
    // Handle cold start
    try  {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial link: $e');
      }
    }
    
    // Handle warm start
    _linkSubscriptions = _appLinks.uriLinkStream.listen((uri) => _handleDeepLink(uri), onError: (e) {
      if (kDebugMode) {
        print('Error handling deep link: $e');
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    final containerId = getContainerIdFromUriLink(uri);

    if (containerId != null && onContainerLink != null) {
      onContainerLink!(containerId);
    }
  }

  static String? getContainerIdFromUriLink(Uri uri) {
    return uri.queryParameters['id'];
  }

  static String? getContainerIdFromStringLink(String uri) {
    final Uri parsedUri = Uri.parse(uri);
    return parsedUri.queryParameters['id'];
  }

  static String generateContainerLink(String containerId) {
    return 'shelfstack://container?id=$containerId';
  }

  void dispose() {
    _linkSubscriptions?.cancel();
  }
}