import 'dart:convert';
import '../models/v2ray_config.dart';

class V2RayHelper {
  static V2RayConfig? parseFromURL(String url) {
    if (url.startsWith('vmess://')) {
      return _parseVmessURL(url);
    }
    // Add more parsing methods for other protocols as needed
    return null;
  }

  static V2RayConfig? _parseVmessURL(String url) {
    final encodedConfig = url.substring(8); // Remove 'vmess://'
    final decodedConfig = utf8.decode(base64Decode(encodedConfig));
    final jsonConfig = json.decode(decodedConfig);

    return V2RayConfig(
      remark: jsonConfig['ps'] ?? '',
      address: jsonConfig['add'] ?? '',
      port: int.parse(jsonConfig['port'] ?? '0'),
      userId: jsonConfig['id'] ?? '',
      alterId: jsonConfig['aid'] ?? '0',
      security: jsonConfig['scy'] ?? 'auto',
      network: jsonConfig['net'] ?? 'tcp',
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
    final base64Str = base64Encode(utf8.encode(jsonStr));
    return 'vmess://$base64Str';
  }
}