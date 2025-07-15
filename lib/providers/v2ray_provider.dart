import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/v2ray_config.dart';
import '../models/log_entry.dart';
import '../utils/constants.dart';
import '../utils/v2ray_helper.dart';
import 'settings_provider.dart';

class V2RayProvider with ChangeNotifier {
  late FlutterV2ray _flutterV2ray;

  // Callback functions for other providers
  Function(String, LogLevel, {String? serverRemark})? _onLogUpdate;

  bool _isConnected = false;
  V2RayConfig? _currentConfig;
  final List<V2RayConfig> _savedConfigs = [];
  V2RayStatus? _lastStatus;

  bool get isConnected => _isConnected;
  V2RayConfig? get currentConfig => _currentConfig;
  List<V2RayConfig> get savedConfigs => List.unmodifiable(_savedConfigs);
  V2RayStatus? get lastStatus => _lastStatus;

  V2RayProvider() {
    _initializeFlutterV2Ray();
    _loadSavedConfigs();
  }

  /// Set callback for logging
  void setLogCallback(Function(String, LogLevel, {String? serverRemark}) callback) {
    _onLogUpdate = callback;
  }

  /// Initialize the FlutterV2ray instance with status callback
  void _initializeFlutterV2Ray() {
    _flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        _handleStatusChange(status);
      },
    );
  }

  /// Handle status changes from V2Ray
  void _handleStatusChange(V2RayStatus status) {
    _lastStatus = status;

    // Update connection state based on status
    final bool wasConnected = _isConnected;
    _isConnected = status.state != "DISCONNECTED";

    // Log status change
    if (_onLogUpdate != null) {
      _onLogUpdate!('Status: ${status.state}', LogLevel.debug,
          serverRemark: _currentConfig?.remark);

      // Log connection state changes
      if (!wasConnected && _isConnected) {
        _onLogUpdate!('Connected successfully', LogLevel.success,
            serverRemark: _currentConfig?.remark);
      } else if (wasConnected && !_isConnected) {
        _onLogUpdate!('Disconnected', LogLevel.info);
      }
    }

    notifyListeners();
  }

  Future<void> _loadSavedConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedConfigsJson = prefs.getStringList(AppConstants.prefKeySavedConfigs) ?? [];
    _savedConfigs.clear();
    _savedConfigs.addAll(savedConfigsJson.map((json) => V2RayConfig.fromJson(jsonDecode(json))));
    notifyListeners();
  }

  Future<void> _saveConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedConfigsJson = _savedConfigs.map((config) => jsonEncode(config.toJson())).toList();
    await prefs.setStringList(AppConstants.prefKeySavedConfigs, savedConfigsJson);
  }

  Future<void> initializeV2Ray() async {
    try {
      await _flutterV2ray.initializeV2Ray();
      if (_onLogUpdate != null) {
        _onLogUpdate!('V2Ray core initialized', LogLevel.info);
      }
    } catch (e) {
      if (_onLogUpdate != null) {
        _onLogUpdate!('Failed to initialize V2Ray: $e', LogLevel.error);
      }
      rethrow;
    }
  }

  Future<void> connect(V2RayConfig config, {SettingsProvider? settingsProvider}) async {
    if (_onLogUpdate != null) {
      _onLogUpdate!('Connecting to ${config.remark}...', LogLevel.info,
          serverRemark: config.remark);
    }

    try {
      if (await _flutterV2ray.requestPermission()) {
        try {
          // Get bypass settings
          List<String>? bypassSubnets;
          bool bypassLAN = true;

          if (settingsProvider != null) {
            bypassSubnets = settingsProvider.bypassSubnets.isNotEmpty
                ? settingsProvider.bypassSubnets
                : null;
            bypassLAN = settingsProvider.bypassLAN;

            if (_onLogUpdate != null) {
              if (bypassLAN) {
                _onLogUpdate!('LAN bypass ENABLED - Local network traffic will bypass VPN', LogLevel.info,
                    serverRemark: config.remark);
              } else {
                _onLogUpdate!('LAN bypass DISABLED - All traffic will go through VPN tunnel', LogLevel.info,
                    serverRemark: config.remark);
              }

              if (bypassSubnets != null && bypassSubnets.isNotEmpty) {
                _onLogUpdate!('Custom bypass subnets: ${bypassSubnets.join(", ")}', LogLevel.info,
                    serverRemark: config.remark);
              } else {
                _onLogUpdate!('No custom bypass subnets configured', LogLevel.info,
                    serverRemark: config.remark);
              }

              if (settingsProvider.blockedApps.isNotEmpty) {
                _onLogUpdate!('${settingsProvider.blockedApps.length} apps will bypass VPN: ${settingsProvider.blockedApps.take(3).join(", ")}${settingsProvider.blockedApps.length > 3 ? "..." : ""}', LogLevel.info,
                    serverRemark: config.remark);
              } else {
                _onLogUpdate!('No blocked apps - all apps will use VPN', LogLevel.info,
                    serverRemark: config.remark);
              }
            }
          }

          await _flutterV2ray.startV2Ray(
            remark: config.remark,
            config: config.getFullConfiguration(
              bypassSubnets: bypassSubnets,
              bypassLAN: bypassLAN,
            ),
            blockedApps: settingsProvider?.blockedApps,
            bypassSubnets: bypassSubnets,
            proxyOnly: false,
          );
          _isConnected = true;
          _currentConfig = config;

          if (_onLogUpdate != null) {
            _onLogUpdate!('Connection started with routing rules applied', LogLevel.success,
                serverRemark: config.remark);
          }

          notifyListeners();
        } catch (e) {
          if (_onLogUpdate != null) {
            _onLogUpdate!('Connection failed: $e', LogLevel.error,
                serverRemark: config.remark);
          }
          throw Exception(AppConstants.errorConnectionFailed);
        }
      } else {
        if (_onLogUpdate != null) {
          _onLogUpdate!('Permission denied', LogLevel.error);
        }
        throw Exception('Permission denied');
      }
    } catch (e) {
      if (_onLogUpdate != null) {
        _onLogUpdate!('Error: $e', LogLevel.error, serverRemark: config.remark);
      }
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_onLogUpdate != null) {
      _onLogUpdate!('Disconnecting...', LogLevel.info,
          serverRemark: _currentConfig?.remark);
    }

    try {
      await _flutterV2ray.stopV2Ray();
      _isConnected = false;
      _currentConfig = null;

      if (_onLogUpdate != null) {
        _onLogUpdate!('Disconnected successfully', LogLevel.info);
      }

      notifyListeners();
    } catch (e) {
      if (_onLogUpdate != null) {
        _onLogUpdate!('Failed to disconnect: $e', LogLevel.error);
      }
      throw Exception('Failed to disconnect');
    }
  }

  Future<int> getServerDelay(V2RayConfig config) async {
    if (_onLogUpdate != null) {
      _onLogUpdate!('Testing server delay for ${config.remark}...', LogLevel.info,
          serverRemark: config.remark);
    }

    try {
      final delay = await _flutterV2ray.getServerDelay(config: config.fullConfiguration);

      if (_onLogUpdate != null) {
        _onLogUpdate!('Server delay: ${delay}ms', LogLevel.info,
            serverRemark: config.remark);
      }

      return delay;
    } catch (e) {
      if (_onLogUpdate != null) {
        _onLogUpdate!('Failed to get server delay: $e', LogLevel.warning,
            serverRemark: config.remark);
      }
      throw Exception('Failed to get server delay');
    }
  }

  Future<void> importConfig(String url) async {
    if (_onLogUpdate != null) {
      _onLogUpdate!('Importing configuration from URL...', LogLevel.info);
    }

    try {
      final config = V2RayHelper.parseFromURL(url);
      if (config != null) {
        addConfig(config);

        if (_onLogUpdate != null) {
          _onLogUpdate!('Configuration imported successfully: ${config.remark}',
              LogLevel.success, serverRemark: config.remark);
        }
      } else {
        if (_onLogUpdate != null) {
          _onLogUpdate!('Invalid configuration URL', LogLevel.error);
        }
        throw Exception('Invalid configuration URL');
      }
    } catch (e) {
      if (_onLogUpdate != null) {
        _onLogUpdate!('Failed to import configuration: $e', LogLevel.error);
      }
      rethrow;
    }
  }

  String exportConfig(V2RayConfig config) {
    try {
      final shareLink = V2RayHelper.generateShareLink(config);

      if (_onLogUpdate != null) {
        _onLogUpdate!('Configuration exported: ${config.remark}',
            LogLevel.info, serverRemark: config.remark);
      }

      return shareLink;
    } catch (e) {
      if (_onLogUpdate != null) {
        _onLogUpdate!('Failed to export configuration: $e', LogLevel.error,
            serverRemark: config.remark);
      }
      rethrow;
    }
  }

  void addConfig(V2RayConfig config) {
    _savedConfigs.add(config);
    _saveConfigs();

    if (_onLogUpdate != null) {
      _onLogUpdate!('Configuration added: ${config.remark}',
          LogLevel.success, serverRemark: config.remark);
    }

    notifyListeners();
  }

  void removeConfig(V2RayConfig config) {
    _savedConfigs.remove(config);
    _saveConfigs();

    if (_onLogUpdate != null) {
      _onLogUpdate!('Configuration removed: ${config.remark}',
          LogLevel.info, serverRemark: config.remark);
    }

    notifyListeners();
  }

  void updateConfig(V2RayConfig oldConfig, V2RayConfig newConfig) {
    final index = _savedConfigs.indexOf(oldConfig);
    if (index != -1) {
      _savedConfigs[index] = newConfig;
      _saveConfigs();

      if (_onLogUpdate != null) {
        _onLogUpdate!('Configuration updated: ${newConfig.remark}',
            LogLevel.info, serverRemark: newConfig.remark);
      }

      notifyListeners();
    }
  }
}