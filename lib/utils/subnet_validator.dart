import 'dart:math';

class SubnetValidator {
  /// Common local network ranges as preset options
  static const List<String> commonLocalRanges = [
    '192.168.0.0/16',  // Private Class C networks
    '10.0.0.0/8',      // Private Class A networks
    '172.16.0.0/12',   // Private Class B networks
    '127.0.0.0/8',     // Loopback addresses
    '169.254.0.0/16',  // Link-local addresses
    '224.0.0.0/4',     // Multicast addresses
  ];

  /// Validate CIDR notation subnet format
  static bool isValidCIDR(String subnet) {
    if (subnet.isEmpty) return false;
    
    final parts = subnet.split('/');
    if (parts.length != 2) return false;
    
    final ipAddress = parts[0];
    final prefixLength = parts[1];
    
    // Validate IP address
    if (!isValidIPAddress(ipAddress)) return false;
    
    // Validate prefix length
    final prefix = int.tryParse(prefixLength);
    if (prefix == null || prefix < 0 || prefix > 32) return false;
    
    return true;
  }
  
  /// Validate IPv4 address format
  static bool isValidIPAddress(String ip) {
    if (ip.isEmpty) return false;
    
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    
    for (final part in parts) {
      final octet = int.tryParse(part);
      if (octet == null || octet < 0 || octet > 255) return false;
    }
    
    return true;
  }
  
  /// Convert CIDR to network address (normalize)
  static String? normalizeCIDR(String subnet) {
    if (!isValidCIDR(subnet)) return null;
    
    final parts = subnet.split('/');
    final ipAddress = parts[0];
    final prefixLength = int.parse(parts[1]);
    
    final ipParts = ipAddress.split('.').map(int.parse).toList();
    final networkMask = _createNetworkMask(prefixLength);
    
    // Apply network mask to get network address
    final networkAddress = <int>[];
    for (int i = 0; i < 4; i++) {
      networkAddress.add(ipParts[i] & networkMask[i]);
    }
    
    return '${networkAddress.join('.')}/$prefixLength';
  }
  
  /// Create network mask from prefix length
  static List<int> _createNetworkMask(int prefixLength) {
    final mask = <int>[0, 0, 0, 0];
    int remainingBits = prefixLength;
    
    for (int i = 0; i < 4; i++) {
      if (remainingBits >= 8) {
        mask[i] = 255;
        remainingBits -= 8;
      } else if (remainingBits > 0) {
        mask[i] = (255 << (8 - remainingBits)) & 255;
        remainingBits = 0;
      } else {
        mask[i] = 0;
      }
    }
    
    return mask;
  }
  
  /// Check if an IP address is within a subnet
  static bool isIPInSubnet(String ipAddress, String subnet) {
    if (!isValidIPAddress(ipAddress) || !isValidCIDR(subnet)) {
      return false;
    }
    
    final parts = subnet.split('/');
    final networkIP = parts[0];
    final prefixLength = int.parse(parts[1]);
    
    final ipParts = ipAddress.split('.').map(int.parse).toList();
    final networkParts = networkIP.split('.').map(int.parse).toList();
    final networkMask = _createNetworkMask(prefixLength);
    
    // Apply mask to both IPs and compare
    for (int i = 0; i < 4; i++) {
      if ((ipParts[i] & networkMask[i]) != (networkParts[i] & networkMask[i])) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Get subnet range information
  static SubnetInfo? getSubnetInfo(String subnet) {
    if (!isValidCIDR(subnet)) return null;
    
    final parts = subnet.split('/');
    final networkIP = parts[0];
    final prefixLength = int.parse(parts[1]);
    
    final networkParts = networkIP.split('.').map(int.parse).toList();
    final networkMask = _createNetworkMask(prefixLength);
    
    // Calculate network address
    final networkAddress = <int>[];
    for (int i = 0; i < 4; i++) {
      networkAddress.add(networkParts[i] & networkMask[i]);
    }
    
    // Calculate broadcast address
    final broadcastAddress = <int>[];
    for (int i = 0; i < 4; i++) {
      broadcastAddress.add(networkAddress[i] | (255 - networkMask[i]));
    }
    
    // Calculate number of hosts
    final hostBits = 32 - prefixLength;
    final totalHosts = pow(2, hostBits).toInt();
    final usableHosts = totalHosts > 2 ? totalHosts - 2 : totalHosts;
    
    return SubnetInfo(
      networkAddress: networkAddress.join('.'),
      broadcastAddress: broadcastAddress.join('.'),
      subnetMask: networkMask.join('.'),
      prefixLength: prefixLength,
      totalHosts: totalHosts,
      usableHosts: usableHosts,
      isPrivate: _isPrivateNetwork(networkAddress.join('.')),
    );
  }
  
  /// Check if IP is in private network range
  static bool _isPrivateNetwork(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    final firstOctet = parts[0];
    final secondOctet = parts[1];
    
    // 10.0.0.0/8
    if (firstOctet == 10) return true;
    
    // 172.16.0.0/12
    if (firstOctet == 172 && secondOctet >= 16 && secondOctet <= 31) return true;
    
    // 192.168.0.0/16
    if (firstOctet == 192 && secondOctet == 168) return true;
    
    // 127.0.0.0/8 (loopback)
    if (firstOctet == 127) return true;
    
    return false;
  }
  
  /// Get description for common network ranges
  static String getSubnetDescription(String subnet) {
    switch (subnet) {
      case '192.168.0.0/16':
        return 'Private Class C networks (home/office networks)';
      case '10.0.0.0/8':
        return 'Private Class A networks (large organizations)';
      case '172.16.0.0/12':
        return 'Private Class B networks (medium organizations)';
      case '127.0.0.0/8':
        return 'Loopback addresses (localhost)';
      case '169.254.0.0/16':
        return 'Link-local addresses (auto-configuration)';
      case '224.0.0.0/4':
        return 'Multicast addresses';
      default:
        final info = getSubnetInfo(subnet);
        if (info != null) {
          return info.isPrivate 
              ? 'Private network (${info.usableHosts} hosts)'
              : 'Public network (${info.usableHosts} hosts)';
        }
        return 'Custom subnet';
    }
  }
}

class SubnetInfo {
  final String networkAddress;
  final String broadcastAddress;
  final String subnetMask;
  final int prefixLength;
  final int totalHosts;
  final int usableHosts;
  final bool isPrivate;
  
  SubnetInfo({
    required this.networkAddress,
    required this.broadcastAddress,
    required this.subnetMask,
    required this.prefixLength,
    required this.totalHosts,
    required this.usableHosts,
    required this.isPrivate,
  });
}
