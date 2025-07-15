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

  String getFullConfiguration({List<String>? bypassSubnets, bool bypassLAN = true}) {
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
          "tag": "proxy",
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
        },
        {
          "tag": "direct",
          "protocol": "freedom",
          "settings": {}
        },
        {
          "tag": "block",
          "protocol": "blackhole",
          "settings": {
            "response": {
              "type": "http"
            }
          }
        }
      ]
    };

    // Add routing rules if bypass subnets are configured
    if ((bypassSubnets != null && bypassSubnets.isNotEmpty) || bypassLAN) {
      final List<Map<String, dynamic>> rules = [];

      // Add bypass subnet rules
      if (bypassSubnets != null && bypassSubnets.isNotEmpty) {
        rules.add({
          "type": "field",
          "ip": bypassSubnets,
          "outboundTag": "direct"
        });
      }

      // Add LAN bypass rules if enabled
      if (bypassLAN) {
        rules.add({
          "type": "field",
          "ip": [
            "127.0.0.0/8",
            "10.0.0.0/8",
            "172.16.0.0/12",
            "192.168.0.0/16",
            "169.254.0.0/16",
            "224.0.0.0/4",
            "240.0.0.0/4"
          ],
          "outboundTag": "direct"
        });
      }

      // Default rule - route everything else through proxy
      rules.add({
        "type": "field",
        "network": "tcp,udp",
        "outboundTag": "proxy"
      });

      config["routing"] = {
        "strategy": "rules",
        "rules": rules
      };
    }

    return json.encode(config);
  }

  // Keep backward compatibility
  String get fullConfiguration => getFullConfiguration();
}