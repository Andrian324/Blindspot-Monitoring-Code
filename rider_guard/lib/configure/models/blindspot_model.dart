class BlindspotData {
  final double distance;   // jarak dari LD2450 (meter)
  final double posX;       // posisi X (mm) - kiri negatif, kanan positif
  final double speed;      // kecepatan dari LD2451 (m/s)
  final int hazardLeft;    // 0=Aman, 1=Waspada, 2=Bahaya
  final int hazardRight;   // 0=Aman, 1=Waspada, 2=Bahaya
  final DateTime timestamp;

  BlindspotData({
    required this.distance,
    required this.posX,
    required this.speed,
    required this.hazardLeft,
    required this.hazardRight,
    required this.timestamp,
  });

  factory BlindspotData.fromJson(Map<String, dynamic> json) {
    return BlindspotData(
      distance: (json['dist'] ?? 0.0).toDouble(),
      posX: (json['posX'] ?? 0.0).toDouble(),
      speed: (json['spd'] ?? 0.0).toDouble(),
      hazardLeft: (json['hL'] ?? 0).toInt(),
      hazardRight: (json['hR'] ?? 0).toInt(),
      timestamp: DateTime.now(),
    );
  }

  // Parse dari string JSON: {"dist":2.50, "posX":120.0, "spd":15.00, "hL":0, "hR":2}
  factory BlindspotData.fromString(String raw) {
    try {
      final cleaned = raw.trim();
      final map = <String, dynamic>{};
      // Hapus kurung kurawal
      final inner = cleaned.replaceAll('{', '').replaceAll('}', '');
      for (final pair in inner.split(',')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim().replaceAll('"', '');
          final val = double.tryParse(parts[1].trim()) ?? 0.0;
          map[key] = val;
        }
      }
      return BlindspotData.fromJson(map);
    } catch (_) {
      return BlindspotData(
        distance: 0, posX: 0, speed: 0,
        hazardLeft: 0, hazardRight: 0,
        timestamp: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toFirestore() => {
    'distance': distance,
    'posX': posX,
    'speed': speed,
    'hazardLeft': hazardLeft,
    'hazardRight': hazardRight,
    'timestamp': timestamp.toIso8601String(),
    'statusLeft': hazardLabel(hazardLeft),
    'statusRight': hazardLabel(hazardRight),
  };

  static String hazardLabel(int level) {
    switch (level) {
      case 2: return 'BAHAYA';
      case 1: return 'WASPADA';
      default: return 'AMAN';
    }
  }
}

class BlindspotSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalAlerts;
  final double maxDistance;
  final String deviceName;

  BlindspotSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.totalAlerts,
    required this.maxDistance,
    required this.deviceName,
  });

  factory BlindspotSession.fromFirestore(Map<String, dynamic> data, String id) {
    return BlindspotSession(
      id: id,
      startTime: DateTime.parse(data['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: data['endTime'] != null ? DateTime.parse(data['endTime']) : null,
      totalAlerts: data['totalAlerts'] ?? 0,
      maxDistance: (data['maxDistance'] ?? 0.0).toDouble(),
      deviceName: data['deviceName'] ?? 'Radar_BlindSpot',
    );
  }
}