import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blindspot_model.dart';
import '../models/fatigue_model.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ======= BLINDSPOT =======

  static Future<String> startBlindspotSession(String deviceName) async {
    final doc = await _db.collection('blindspot_sessions').add({
      'startTime': DateTime.now().toIso8601String(),
      'deviceName': deviceName,
      'totalAlerts': 0,
      'maxDistance': 0.0,
      'status': 'active',
    });
    return doc.id;
  }

  static Future<void> saveBlindspotData(String sessionId, BlindspotData data) async {
    await _db
        .collection('blindspot_sessions')
        .doc(sessionId)
        .collection('data_points')
        .add(data.toFirestore());

    // Update session summary
    if (data.hazardLeft == 2 || data.hazardRight == 2) {
      await _db.collection('blindspot_sessions').doc(sessionId).update({
        'totalAlerts': FieldValue.increment(1),
        'maxDistance': FieldValue.increment(0), // handled separately
      });
    }
  }

  static Future<void> endBlindspotSession(String sessionId, int totalAlerts, double maxDist) async {
    await _db.collection('blindspot_sessions').doc(sessionId).update({
      'endTime': DateTime.now().toIso8601String(),
      'totalAlerts': totalAlerts,
      'maxDistance': maxDist,
      'status': 'completed',
    });
  }

  static Stream<List<BlindspotSession>> blindspotSessionsStream() {
    return _db
        .collection('blindspot_sessions')
        .orderBy('startTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BlindspotSession.fromFirestore(d.data(), d.id))
            .toList());
  }

  // ======= FATIGUE =======

  static Future<String> startFatigueSession() async {
    final doc = await _db.collection('fatigue_sessions').add({
      'startTime': DateTime.now().toIso8601String(),
      'deviceName': 'FatigueMonitor_Adit',
      'maxDuration': 0,
      'totalJiggles': 0,
      'maxFatigueLevel': 'NORMAL',
      'status': 'active',
    });
    return doc.id;
  }

  static Future<void> saveFatigueData(String sessionId, FatigueData data) async {
    await _db
        .collection('fatigue_sessions')
        .doc(sessionId)
        .collection('data_points')
        .add(data.toFirestore());

    // Update session summary with highest fatigue level
    await _db.collection('fatigue_sessions').doc(sessionId).update({
      'maxDuration': data.durationSeconds,
      if (data.isAlertGelisah) 'totalJiggles': FieldValue.increment(1),
    });
  }

  static Future<void> endFatigueSession(String sessionId, int maxDur, int jiggles, String level) async {
    await _db.collection('fatigue_sessions').doc(sessionId).update({
      'endTime': DateTime.now().toIso8601String(),
      'maxDuration': maxDur,
      'totalJiggles': jiggles,
      'maxFatigueLevel': level,
      'status': 'completed',
    });
  }

  static Stream<List<FatigueSession>> fatigueSessionsStream() {
    return _db
        .collection('fatigue_sessions')
        .orderBy('startTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FatigueSession.fromFirestore(d.data(), d.id))
            .toList());
  }
}