import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/v2ray_config.dart';

class V2RayHelper {
  static V2RayConfig? parseFromURL(String url) {
    try {
      if (url.startsWith('vmess://')) {
        return _parseVmessURL(url);
      } else if (url.startsWith('vless://')) {
        return _parseVlessURL(url);
      } else if (url.startsWith('trojan://')) {
        return _parseTrojanURL(url);
      }
      // Add more protocols as needed
    } catch (e) {
      debugPrint('Error parsing URL: $e');
    }
    return null;
  }

  static V2RayConfig? _parseVmessURL(String url) {
    String configStr = url.substring(8); // Remove 'vmess://'
    if (!configStr.startsWith('{')) {
      // If it's base64 encoded
      configStr = utf8.decode(base64Decode(configStr.replaceAll('-', '+').replaceAll('_', '/')));
    }
    final jsonConfig = json.decode(configStr);
    return V2RayConfig(
      remark: jsonConfig['ps'] ?? jsonConfig['name'] ?? '',
      address: jsonConfig['add'] ?? '',
      port: int.parse(jsonConfig['port']?.toString() ?? '0'),
      userId: jsonConfig['id'] ?? '',
      alterId: jsonConfig['aid']?.toString() ?? '0',
      security: jsonConfig['scy'] ?? jsonConfig['security'] ?? 'auto',
      network: jsonConfig['net'] ?? 'tcp',
    );
  }

  static V2RayConfig? _parseVlessURL(String url) {
    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;
    return V2RayConfig(
      remark: queryParams['remarks'] ?? '',
      address: uri.host,
      port: uri.port,
      userId: uri.userInfo,
      alterId: '0', // VLESS doesn't use alterId
      security: queryParams['security'] ?? 'none',
      network: queryParams['type'] ?? 'tcp',
    );
  }

  static V2RayConfig? _parseTrojanURL(String url) {
    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;
    return V2RayConfig(
      remark: queryParams['remarks'] ?? '',
      address: uri.host,
      port: uri.port,
      userId: uri.userInfo,
      alterId: '0', // Trojan doesn't use alterId
      security: 'tls', // Trojan always uses TLS
      network: queryParams['type'] ?? 'tcp',
    );
  }

  static String generateShareLink(V2RayConfig config) {
    final Map<String, dynamic> shareConfig = {
      'v': '2',
      'ps': config.remark,
      'add': config.address,
      'port': config.port.toString(),
      'id': config.userId,
      'aid': config.alterId,
      'scy': config.security,
      'net': config.network,
    };
    final jsonStr = json.encode(shareConfig);
    final base64Str = base64UrlEncode(utf8.encode(jsonStr)).replaceAll('=', '');
    return 'vmess://$base64Str';
  }

  static Future<V2RayConfig?> importConfigFile(String filePath) async {
    try {
      final String contents = await rootBundle.loadString(filePath);
      final Map<String, dynamic> jsonConfig = json.decode(contents);
      
      return V2RayConfig(
        remark: jsonConfig['remark'] ?? '',
        address: jsonConfig['address'] ?? '',
        port: jsonConfig['port'] ?? 0,
        userId: jsonConfig['userId'] ?? '',
        alterId: jsonConfig['alterId'] ?? '0',
        security: jsonConfig['security'] ?? 'auto',
        network: jsonConfig['network'] ?? 'tcp',
      );
    } catch (e) {
      debugPrint('Error importing configuration file: $e');
      return null;
    }
  }
}