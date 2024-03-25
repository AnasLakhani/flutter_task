import 'package:flutter/material.dart';

mixin MyUtils {
  // Define a map to map domains to their corresponding icons
  static Map<String, IconData> domainIconMap = {
    'instagram': Icons.camera,
    'facebook': Icons.facebook,
    'tiktok': Icons.tiktok,
  };

// Function to get the domain icon based on the URL
  static IconData getDomainIcon(String url) {
    // Extract the domain from the URL
    // String domain = Uri.parse(url).host;
    // url = 'facebook';
    // Check if the domain exists in the map

    String domain;

    if (url.contains(":")) {
      domain = extractDomain(url)
          .replaceAll('www.', '')
          .split('.')
          .first
          .toLowerCase();
    } else {
      domain = (url).replaceAll('www.', '').split('.').first.toLowerCase();
    }
    if (domainIconMap.containsKey(domain)) {
      // Return the corresponding icon
      return domainIconMap[domain]!;
    } else {
      // Return a default icon for other domains
      return Icons.public;
    }
  }

  static bool isValidUrl(String url) {
    // Regular expression for URL validation
    // This is a basic example, you may need to adjust it as needed
    final RegExp urlRegex = RegExp(
      r"^(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+",
      caseSensitive: false,
      multiLine: false,
    );
    return urlRegex.hasMatch(url);
  }

  static String extractDomain(String url) {
    return Uri.parse(url).host;
  }
}
