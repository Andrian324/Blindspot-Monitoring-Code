import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../models/fatigue_model.dart';
import '../services/bluetooth_service.dart';
import '../services/firebase_service.dart';

class FatigueProvider extends ChangeNotifier {
  final BleService _bleService = BleService();

  FatigueData _currentData = FatigueData.empty();
  String _connectionStatus = 'disconnected';
  String? _sessionId;
  final List<String> _serialLog = [];
  final List<FatigueData> _chartHistory = [];
  final List<DiscoveredDevice> _scannedDevices = [];
  String? _connectedDeviceId;

  // Getters
  FatigueData get currentData => _currentData;
  String get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus == 'connected';
  bool get isScanning => _connectionStatus == 'scanning';
  List<String> get serialLog => List.unmodifiable(_serialLog);
  List<FatigueData> get chartHistory => List.unmodifiable(_chartHistory);
  List<DiscoveredDevice> get scannedDevices => List.unmodifiable(_scannedDevices);
  String? get connectedDeviceId => _connectedDeviceId;

  FatigueProvider() {
    _bleService.statusStream.listen((status) {
      _connectionStatus = status;
      notifyListeners();
    });

    _bleService.devicesStream.listen((device) {
      if (!_scannedDevices.any((d) => d.id == device.id)) {
        _scannedDevices.add(device);
        notifyListeners();
      }
    });

    _bleService.dataStream.listen((raw) {
      _processIncoming(raw);
    });
  }

  void startScan() {
    _scannedDevices.clear();
    _bleService.startScan();
    notifyListeners();
  }

  void stopScan() => _bleService.stopScan();

  Future<void> connectToDevice(DiscoveredDevice device) async {
    _bleService.stopScan();
    await _bleService.connect(device.id);
    _connectedDeviceId = device.id;
    _sessionId = await FirebaseService.startFatigueSession();
    _chartHistory.clear();
    _serialLog.clear();
    _currentData = FatigueData.empty();
    notifyListeners();
  }

  Future<void> disconnect() async {
    if (_sessionId != null) {
      await FirebaseService.endFatigueSession(
        _sessionId!,
        _currentData.durationSeconds,
        _currentData.jiggleCount,
        _currentData.fatigueLevel,
      );
    }
    await _bleService.disconnect();
    _connectedDeviceId = null;
    _sessionId = null;
    notifyListeners();
  }

  void _processIncoming(String raw) {
    _serialLog.add('[${_timeNow()}] $raw');
    if (_serialLog.length > 200) _serialLog.removeAt(0);

    final newData = FatigueData.fromBleString(raw, _currentData);
    _currentData = newData;

    _chartHistory.add(newData);
    if (_chartHistory.length > 60) _chartHistory.removeAt(0);

    if (_sessionId != null) {
      FirebaseService.saveFatigueData(_sessionId!, newData);
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