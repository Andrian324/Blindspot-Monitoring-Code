import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../models/blindspot_model.dart';
import '../services/bluetooth_service.dart';
import '../services/firebase_service.dart';

class BlindspotProvider extends ChangeNotifier {
  final BlindspotBleService _bleService = BlindspotBleService();

  BlindspotData? _currentData;
  String _connectionStatus = 'disconnected';
  String? _sessionId;
  final List<String> _serialLog = [];
  final List<BlindspotData> _chartHistory = [];
  int _totalAlerts = 0;
  double _maxDistance = 0;
  DiscoveredDevice? _connectedDevice;
  final List<DiscoveredDevice> _availableDevices = [];

  // Getters
  BlindspotData? get currentData => _currentData;
  String get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus == 'connected';
  List<String> get serialLog => List.unmodifiable(_serialLog);
  List<BlindspotData> get chartHistory => List.unmodifiable(_chartHistory);
  int get totalAlerts => _totalAlerts;
  String? get sessionId => _sessionId;
  DiscoveredDevice? get connectedDevice => _connectedDevice;
  List<DiscoveredDevice> get availableDevices => List.unmodifiable(_availableDevices);

  BlindspotProvider() {
    _bleService.statusStream.listen((status) {
      _connectionStatus = status;
      notifyListeners();
    });

    _bleService.dataStream.listen((raw) {
      _processIncoming(raw);
    });

    _bleService.devicesStream.listen((device) {
      if (!_availableDevices.any((d) => d.id == device.id)) {
        _availableDevices.add(device);
        notifyListeners();
      }
    });
  }

  void startScan() {
    _availableDevices.clear();
    _bleService.startScan();
    notifyListeners();
  }

  void stopScan() => _bleService.stopScan();

  Future<void> connectToDevice(DiscoveredDevice device) async {
    await _bleService.connect(device.id);
    _connectedDevice = device;
    _sessionId = await FirebaseService.startBlindspotSession(device.name);
    _totalAlerts = 0;
    _maxDistance = 0;
    _chartHistory.clear();
    _serialLog.clear();
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (_sessionId != null) {
      await FirebaseService.endBlindspotSession(_sessionId!, _totalAlerts, _maxDistance);
    }
    await _bleService.disconnect();
    _connectedDevice = null;
    _sessionId = null;
    notifyListeners();
  }

  void _processIncoming(String raw) {
    // Add to serial log (max 200 lines)
    _serialLog.add('[${_timeNow()}] $raw');
    if (_serialLog.length > 200) _serialLog.removeAt(0);

    // Parse JSON from ESP32 Notifikasi
    if (raw.startsWith('{')) {
      try {
        final data = BlindspotData.fromString(raw);
        _currentData = data;

        // Chart history (max 60 points)
        _chartHistory.add(data);
        if (_chartHistory.length > 60) _chartHistory.removeAt(0);

        // Alert counting
        if (data.hazardLeft == 2 || data.hazardRight == 2) {
          _totalAlerts++;
        }
        if (data.distance > _maxDistance) _maxDistance = data.distance;

        // Save to Firebase
        if (_sessionId != null) {
          FirebaseService.saveBlindspotData(_sessionId!, data);
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _bleService.dispose();
    super.dispose();
  }
}