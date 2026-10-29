class FatigueData {
  final double sensor1; // FSR pin 32
  final double sensor2; // FSR pin 34
  final double sensor3; // FSR pin 35
  final double sensor4; // FSR pin 33
  final int durationSeconds;
  final double avgLoad;
  final bool isJiggling;
  final bool isAlertGelisah;
  final int jiggleCount;
  final DateTime timestamp;

  FatigueData({
    required this.sensor1,
    required this.sensor2,
    required this.sensor3,
    required this.sensor4,
    required this.durationSeconds,
    required this.avgLoad,
    required this.isJiggling,
    required this.isAlertGelisah,
    required this.jiggleCount,
    required this.timestamp,
  });

  // Parse dari BLE: "D:120,B:8.5" (periodik) atau "ALERT: GELISAH" (alert)
  factory FatigueData.fromBleString(String raw, FatigueData? previous) {
    if (raw.trim() == 'ALERT: GELISAH') {
      return FatigueData(
        sensor1: previous?.sensor1 ?? 0,
        sensor2: previous?.sensor2 ?? 0,
        sensor3: previous?.sensor3 ?? 0,
        sensor4: previous?.sensor4 ?? 0,
        durationSeconds: previous?.durationSeconds ?? 0,
        avgLoad: previous?.avgLoad ?? 0,
        isJiggling: true,
        isAlertGelisah: true,
        jiggleCount: (previous?.jiggleCount ?? 0) + 3,
        timestamp: DateTime.now(),
      );
    }

    try {
      final parts = raw.trim().split(',');
      int dur = 0;
      double beban = 0;
      for (final p in parts) {
        if (p.startsWith('D:')) dur = int.tryParse(p.substring(2)) ?? 0;
        if (p.startsWith('B:')) beban = double.tryParse(p.substring(2)) ?? 0;
      }
      return FatigueData(
        sensor1: previous?.sensor1 ?? 0,
        sensor2: previous?.sensor2 ?? 0,
        sensor3: previous?.sensor3 ?? 0,
        sensor4: previous?.sensor4 ?? 0,
        durationSeconds: dur,
        avgLoad: beban,
        isJiggling: false,
        isAlertGelisah: false,
        jiggleCount: previous?.jiggleCount ?? 0,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      return FatigueData.empty();
    }
  }

  // Parse dari serial monitor full: "S1:8.5 S2:7.2 S3:9.1 S4:6.8 | D:120s | G:2"
  factory FatigueData.fromSerial(String raw) {
    double s1 = 0, s2 = 0, s3 = 0, s4 = 0;
    int dur = 0, g = 0;
    try {
      final parts = raw.split('|');
      if (parts.isNotEmpty) {
        final sensors = parts[0].trim().split(RegExp(r'\s+'));
        for (final s in sensors) {
          if (s.startsWith('S1:')) s1 = double.tryParse(s.substring(3)) ?? 0;
          if (s.startsWith('S2:')) s2 = double.tryParse(s.substring(3)) ?? 0;
          if (s.startsWith('S3:')) s3 = double.tryParse(s.substring(3)) ?? 0;
          if (s.startsWith('S4:')) s4 = double.tryParse(s.substring(3)) ?? 0;
        }
      }
      if (parts.length > 1) {
        final ds = parts[1].trim();
        if (ds.startsWith('D:')) dur = int.tryParse(ds.replaceAll('D:', '').replaceAll('s', '').trim()) ?? 0;
      }
      if (parts.length > 2) {
        final gs = parts[2].trim();
        if (gs.startsWith('G:')) g = int.tryParse(gs.replaceAll('G:', '').split(' ').first) ?? 0;
      }
    } catch (_) {}

    return FatigueData(
      sensor1: s1, sensor2: s2, sensor3: s3, sensor4: s4,
      durationSeconds: dur,
      avgLoad: (s1 + s2 + s3 + s4) / 4,
      isJiggling: raw.contains('JIGGLE'),
      isAlertGelisah: raw.contains('ALERT: GELISAH') || raw.contains('GELISAH'),
      jiggleCount: g,
      timestamp: DateTime.now(),
    );
  }

  factory FatigueData.empty() => FatigueData(
    sensor1: 0, sensor2: 0, sensor3: 0, sensor4: 0,
    durationSeconds: 0, avgLoad: 0,
    isJiggling: false, isAlertGelisah: false, jiggleCount: 0,
    timestamp: DateTime.now(),
  );

  String get fatigueLevel {
    if (durationSeconds >= 1800) return 'KRITIS'; // 30 menit
    if (durationSeconds >= 900) return 'LELAH';   // 15 menit
    if (durationSeconds >= 600) return 'WASPADA'; // 10 menit
    return 'NORMAL';
  }

  Map<String, dynamic> toFirestore() => {
    'sensor1': sensor1, 'sensor2': sensor2,
    'sensor3': sensor3, 'sensor4': sensor4,
    'durationSeconds': durationSeconds,
    'avgLoad': avgLoad,
    'isAlertGelisah': isAlertGelisah,
    'jiggleCount': jiggleCount,
    'fatigueLevel': fatigueLevel,
    'timestamp': timestamp.toIso8601String(),
  };
}

class FatigueSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int maxDuration;
  final int totalJiggles;
  final String maxFatigueLevel;

  FatigueSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.maxDuration,
    required this.totalJiggles,
    required this.maxFatigueLevel,
  });

  factory FatigueSession.fromFirestore(Map<String, dynamic> data, String id) {
    return FatigueSession(
      id: id,
      startTime: DateTime.parse(data['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: data['endTime'] != null ? DateTime.parse(data['endTime']) : null,
      maxDuration: data['maxDuration'] ?? 0,
      totalJiggles: data['totalJiggles'] ?? 0,
      maxFatigueLevel: data['maxFatigueLevel'] ?? 'NORMAL',
    );
  }
}