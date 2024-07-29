import 'dart:convert';

class V2RayConfig {
  final String remark;
  final String address;
  final int port;
  final String userId;
  final String alterId;
  final String security;
  final String network;

  V2RayConfig({
    required this.remark,
    required this.address,
    required this.port,
    required this.userId,
    required this.alterId,
    required this.security,
    required this.network,
  });

  Map<String, dynamic> toJson() {
    return {
      'remark': remark,
      'address': address,
      'port': port,
      'userId': userId,
      'alterId': alterId,
      'security': security,
      'network': network,
    };
  }

  factory V2RayConfig.fromJson(Map<String, dynamic> json) {
    return V2RayConfig(
      remark: json['remark'],
      address: json['address'],
      port: json['port'],
      userId: json['userId'],
      alterId: json['alterId'],
      security: json['security'],
      network: json['network'],
    );
  }

  String get fullConfiguration {
    final Map<String, dynamic> config = {
      "inbounds": [
        {
          "port": 1080,
          "listen": "127.0.0.1",
          "protocol": "socks",
          "settings": {
            "udp": true
          }
        }
      ],
      "outbounds": [
        {
          "protocol": "vmess",
          "settings": {
            "vnext": [
              {
                "address": address,
                "port": port,
                "users": [
                  {
                    "id": userId,
                    "alterId": int.parse(alterId),
                    "security": security
                  }
                ]
              }
            ]
          },
          "streamSettings": {
            "network": network
          }
        }
      ]
    };

    return json.encode(config);
  }
}