import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/v2ray_config.dart';
import '../utils/constants.dart';

class V2RayProvider with ChangeNotifier {
  final FlutterV2ray _flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      print('V2Ray status changed: $status');
    },
  );

  bool _isConnected = false;
  V2RayConfig? _currentConfig;
  List<V2RayConfig> _savedConfigs = [];

  bool get isConnected => _isConnected;
  V2RayConfig? get currentConfig => _currentConfig;
  List<V2RayConfig> get savedConfigs => _savedConfigs;

  V2RayProvider() {
    _loadSavedConfigs();
  }

  Future<void> _loadSavedConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedConfigsJson = prefs.getStringList(AppConstants.prefKeySavedConfigs) ?? [];
    _savedConfigs = savedConfigsJson.map((json) => V2RayConfig.fromJson(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> _saveCofigs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedConfigsJson = _savedConfigs.map((config) => jsonEncode(config.toJson())).toList();
    await prefs.setStringList(AppConstants.prefKeySavedConfigs, savedConfigsJson);
  }

  Future<void> initializeV2Ray() async {
    await _flutterV2ray.initializeV2Ray();
  }

  Future<void> connect(V2RayConfig config) async {
    if (await _flutterV2ray.requestPermission()) {
      try {
        await _flutterV2ray.startV2Ray(
          remark: config.remark,
          config: config.fullConfiguration,
          blockedApps: null,
          bypassSubnets: null,
          proxyOnly: false,
        );
        _isConnected = true;
        _currentConfig = config;
        notifyListeners();
      } catch (e) {
        throw Exception(AppConstants.errorConnectionFailed);
      }
    } else {
      throw Exception('Permission denied');
    }
  }

  Future<void> disconnect() async {
    try {
      await _flutterV2ray.stopV2Ray();
      _isConnected = false;
      _currentConfig = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to disconnect');
    }
  }

  Future<int> getServerDelay(V2RayConfig config) async {
    try {
      return await _flutterV2ray.getServerDelay(config: config.fullConfiguration);
    } catch (e) {
      throw Exception('Failed to get server delay');
    }
  }

  void addConfig(V2RayConfig config) {
    _savedConfigs.add(config);
    _saveCofigs();
    notifyListeners();
  }

  void removeConfig(V2RayConfig config) {
    _savedConfigs.remove(config);
    _saveCofigs();
    notifyListeners();
  }

  void updateConfig(V2RayConfig oldConfig, V2RayConfig newConfig) {
    final index = _savedConfigs.indexOf(oldConfig);
    if (index != -1) {
      _savedConfigs[index] = newConfig;
      _saveCofigs();
      notifyListeners();
    }
  }
}