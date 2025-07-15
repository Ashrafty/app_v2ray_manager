import 'dart:typed_data';

class AppInfo {
  final String packageName;
  final String appName;
  final String version;
  final Uint8List? icon;
  final bool isSystemApp;
  final bool isEnabled;
  final AppCategory category;

  AppInfo({
    required this.packageName,
    required this.appName,
    required this.version,
    this.icon,
    required this.isSystemApp,
    required this.isEnabled,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfo &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;

  @override
  String toString() => 'AppInfo(packageName: $packageName, appName: $appName)';
}

enum AppCategory {
  social,
  gaming,
  streaming,
  productivity,
  finance,
  shopping,
  communication,
  entertainment,
  education,
  health,
  travel,
  news,
  photography,
  music,
  system,
  other,
}

extension AppCategoryExtension on AppCategory {
  String get displayName {
    switch (this) {
      case AppCategory.social:
        return 'Social Media';
      case AppCategory.gaming:
        return 'Gaming';
      case AppCategory.streaming:
        return 'Streaming';
      case AppCategory.productivity:
        return 'Productivity';
      case AppCategory.finance:
        return 'Finance & Banking';
      case AppCategory.shopping:
        return 'Shopping';
      case AppCategory.communication:
        return 'Communication';
      case AppCategory.entertainment:
        return 'Entertainment';
      case AppCategory.education:
        return 'Education';
      case AppCategory.health:
        return 'Health & Fitness';
      case AppCategory.travel:
        return 'Travel';
      case AppCategory.news:
        return 'News';
      case AppCategory.photography:
        return 'Photography';
      case AppCategory.music:
        return 'Music & Audio';
      case AppCategory.system:
        return 'System';
      case AppCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case AppCategory.social:
        return '👥';
      case AppCategory.gaming:
        return '🎮';
      case AppCategory.streaming:
        return '📺';
      case AppCategory.productivity:
        return '💼';
      case AppCategory.finance:
        return '💰';
      case AppCategory.shopping:
        return '🛒';
      case AppCategory.communication:
        return '💬';
      case AppCategory.entertainment:
        return '🎬';
      case AppCategory.education:
        return '📚';
      case AppCategory.health:
        return '🏥';
      case AppCategory.travel:
        return '✈️';
      case AppCategory.news:
        return '📰';
      case AppCategory.photography:
        return '📷';
      case AppCategory.music:
        return '🎵';
      case AppCategory.system:
        return '⚙️';
      case AppCategory.other:
        return '📱';
    }
  }

  static AppCategory categorizeApp(String packageName, String appName) {
    final lowerPackage = packageName.toLowerCase();
    final lowerName = appName.toLowerCase();

    // Social Media
    if (lowerPackage.contains('facebook') ||
        lowerPackage.contains('instagram') ||
        lowerPackage.contains('twitter') ||
        lowerPackage.contains('tiktok') ||
        lowerPackage.contains('snapchat') ||
        lowerPackage.contains('linkedin') ||
        lowerPackage.contains('reddit') ||
        lowerName.contains('social')) {
      return AppCategory.social;
    }

    // Gaming
    if (lowerPackage.contains('game') ||
        lowerPackage.contains('play') ||
        lowerName.contains('game') ||
        lowerName.contains('play')) {
      return AppCategory.gaming;
    }

    // Streaming
    if (lowerPackage.contains('netflix') ||
        lowerPackage.contains('youtube') ||
        lowerPackage.contains('spotify') ||
        lowerPackage.contains('twitch') ||
        lowerPackage.contains('hulu') ||
        lowerPackage.contains('disney') ||
        lowerName.contains('stream') ||
        lowerName.contains('video')) {
      return AppCategory.streaming;
    }

    // Finance
    if (lowerPackage.contains('bank') ||
        lowerPackage.contains('finance') ||
        lowerPackage.contains('payment') ||
        lowerPackage.contains('wallet') ||
        lowerName.contains('bank') ||
        lowerName.contains('pay')) {
      return AppCategory.finance;
    }

    // Shopping
    if (lowerPackage.contains('shop') ||
        lowerPackage.contains('amazon') ||
        lowerPackage.contains('ebay') ||
        lowerPackage.contains('store') ||
        lowerName.contains('shop') ||
        lowerName.contains('market')) {
      return AppCategory.shopping;
    }

    // Communication
    if (lowerPackage.contains('whatsapp') ||
        lowerPackage.contains('telegram') ||
        lowerPackage.contains('messenger') ||
        lowerPackage.contains('discord') ||
        lowerPackage.contains('skype') ||
        lowerPackage.contains('zoom') ||
        lowerName.contains('chat') ||
        lowerName.contains('message')) {
      return AppCategory.communication;
    }

    // System apps
    if (lowerPackage.contains('android') ||
        lowerPackage.contains('google') ||
        lowerPackage.contains('system') ||
        lowerPackage.startsWith('com.android')) {
      return AppCategory.system;
    }

    return AppCategory.other;
  }
}
