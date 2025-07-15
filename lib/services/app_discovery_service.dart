import 'dart:typed_data';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart' as installed_apps;
import '../models/app_info.dart';

class AppDiscoveryService {
  /// Get all installed apps on the device
  static Future<List<AppInfo>> getInstalledApps({
    bool includeSystemApps = false,
  }) async {
    try {
      final List<installed_apps.AppInfo> apps = await InstalledApps.getInstalledApps(
        includeSystemApps,
        true, // withIcon
        "", // packageNamePrefix (empty for all apps)
      );

      // If we got real apps, return them
      if (apps.isNotEmpty) {
        return apps.map((app) => _convertToAppInfo(app)).toList();
      }

      // Fallback to mock data if no real apps found
      return _getMockApps();
    } catch (e) {
      print('Error getting installed apps: $e');
      // Return mock data for development/testing
      return _getMockApps();
    }
  }

  /// Convert installed_apps AppInfo to our AppInfo model
  static AppInfo _convertToAppInfo(installed_apps.AppInfo installedApp) {
    final category = AppCategoryExtension.categorizeApp(
      installedApp.packageName,
      installedApp.name,
    );

    // Determine if it's a system app based on package name
    final isSystemApp = installedApp.packageName.startsWith('com.android') ||
        installedApp.packageName.startsWith('com.google.android') ||
        installedApp.packageName.startsWith('android');

    return AppInfo(
      packageName: installedApp.packageName,
      appName: installedApp.name,
      version: installedApp.versionName,
      icon: installedApp.icon,
      isSystemApp: isSystemApp,
      isEnabled: true, // installed_apps doesn't provide enabled status
      category: category,
    );
  }

  /// Get mock apps for development/testing
  static List<AppInfo> _getMockApps() {
    return [
      // Social Media
      AppInfo(
        packageName: 'com.facebook.katana',
        appName: 'Facebook',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.social,
      ),
      AppInfo(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.social,
      ),
      AppInfo(
        packageName: 'com.twitter.android',
        appName: 'Twitter',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.social,
      ),
      
      // Gaming
      AppInfo(
        packageName: 'com.supercell.clashofclans',
        appName: 'Clash of Clans',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.gaming,
      ),
      AppInfo(
        packageName: 'com.king.candycrushsaga',
        appName: 'Candy Crush Saga',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.gaming,
      ),
      
      // Streaming
      AppInfo(
        packageName: 'com.netflix.mediaclient',
        appName: 'Netflix',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.streaming,
      ),
      AppInfo(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.streaming,
      ),
      AppInfo(
        packageName: 'com.spotify.music',
        appName: 'Spotify',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.music,
      ),
      
      // Finance
      AppInfo(
        packageName: 'com.chase.sig.android',
        appName: 'Chase Mobile',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.finance,
      ),
      AppInfo(
        packageName: 'com.paypal.android.p2pmobile',
        appName: 'PayPal',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.finance,
      ),
      
      // Communication
      AppInfo(
        packageName: 'com.whatsapp',
        appName: 'WhatsApp',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.communication,
      ),
      AppInfo(
        packageName: 'org.telegram.messenger',
        appName: 'Telegram',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.communication,
      ),
      
      // Shopping
      AppInfo(
        packageName: 'com.amazon.mShop.android.shopping',
        appName: 'Amazon Shopping',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.shopping,
      ),
      
      // Productivity
      AppInfo(
        packageName: 'com.microsoft.office.outlook',
        appName: 'Microsoft Outlook',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.productivity,
      ),
      AppInfo(
        packageName: 'com.google.android.apps.docs',
        appName: 'Google Docs',
        version: '1.0.0',
        isSystemApp: false,
        isEnabled: true,
        category: AppCategory.productivity,
      ),
      
      // System Apps
      AppInfo(
        packageName: 'com.android.chrome',
        appName: 'Chrome',
        version: '1.0.0',
        isSystemApp: true,
        isEnabled: true,
        category: AppCategory.system,
      ),
      AppInfo(
        packageName: 'com.google.android.gm',
        appName: 'Gmail',
        version: '1.0.0',
        isSystemApp: true,
        isEnabled: true,
        category: AppCategory.system,
      ),
    ];
  }

  /// Check if an app can be blocked (some system apps cannot be blocked)
  static bool canBlockApp(AppInfo app) {
    // Don't allow blocking critical system apps
    final criticalApps = [
      'com.android.settings',
      'com.android.systemui',
      'com.android.phone',
      'com.android.dialer',
      'com.android.contacts',
      'com.android.launcher',
      'com.android.launcher3',
      'com.google.android.gms',
      'com.google.android.gsf',
      'android',
    ];

    // Don't block our own app
    if (app.packageName == 'com.example.app_v2ray_manager') {
      return false;
    }

    return !criticalApps.contains(app.packageName);
  }

  /// Get preset app categories for quick selection
  static Map<AppCategory, List<String>> getPresetCategories() {
    return {
      AppCategory.social: [
        'com.facebook.katana',
        'com.instagram.android',
        'com.twitter.android',
        'com.snapchat.android',
        'com.linkedin.android',
        'com.reddit.frontpage',
      ],
      AppCategory.gaming: [
        'com.supercell.clashofclans',
        'com.king.candycrushsaga',
        'com.mojang.minecraftpe',
        'com.roblox.client',
      ],
      AppCategory.streaming: [
        'com.netflix.mediaclient',
        'com.google.android.youtube',
        'com.spotify.music',
        'com.hulu.plus',
        'com.disney.disneyplus',
      ],
      AppCategory.finance: [
        'com.chase.sig.android',
        'com.paypal.android.p2pmobile',
        'com.bankofamerica.digitalwallet',
        'com.wellsfargo.mobile',
      ],
    };
  }
}
