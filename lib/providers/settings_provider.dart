// settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _bypassLAN = true;
  List<String> _blockedApps = [];
  List<String> _bypassSubnets = ['127.0.0.1/8', '192.168.0.0/16'];

  bool get bypassLAN => _bypassLAN;
  List<String> get blockedApps => _blockedApps;
  List<String> get bypassSubnets => _bypassSubnets;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _bypassLAN = _prefs.getBool('bypassLAN') ?? true;
    _blockedApps = _prefs.getStringList('blockedApps') ?? [];
    _bypassSubnets = _prefs.getStringList('bypassSubnets') ?? ['127.0.0.1/8', '192.168.0.0/16'];
    notifyListeners();
  }

  Future<void> setBypassLAN(bool value) async {
    _bypassLAN = value;
    await _prefs.setBool('bypassLAN', value);
    notifyListeners();
  }

  Future<void> setBlockedApps(List<String> apps) async {
    _blockedApps = apps;
    await _prefs.setStringList('blockedApps', apps);
    notifyListeners();
  }

  Future<void> setBypassSubnets(List<String> subnets) async {
    _bypassSubnets = subnets;
    await _prefs.setStringList('bypassSubnets', subnets);
    notifyListeners();
  }
}