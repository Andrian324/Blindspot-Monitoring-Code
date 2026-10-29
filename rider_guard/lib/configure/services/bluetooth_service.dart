import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// =========================================================
//  BLINDSPOT SERVICE (BLE - Cross-platform like Fatigue)
// =========================================================
class BlindspotBleService {
  static const String _serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String _charUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

  final _ble = FlutterReactiveBle();
  final _dataController = StreamController<String>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  final _devicesController = StreamController<DiscoveredDevice>.broadcast();

  StreamSubscription? _scanSub;
  StreamSubscription? _connectSub;
  StreamSubscription? _notifySub;
  String? _connectedDeviceId;

  static bool get isSupported => true; // BLE is supported on all platforms

  Stream<String> get dataStream => _dataController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<DiscoveredDevice> get devicesStream => _devicesController.stream;
  bool get isConnected => _connectedDeviceId != null;

  void startScan() {
    _statusController.add('scanning');
    _scanSub?.cancel();
    _scanSub = _ble
        .scanForDevices(
          withServices: [Uuid.parse(_serviceUuid)],
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (device) {
            _devicesController.add(device);
          },
          onError: (e) {
            _statusController.add('scan_error: $e');
          },
        );
  }

  void stopScan() => _scanSub?.cancel();

  Future<void> connect(String deviceId) async {
    _statusController.add('connecting');
    _connectSub?.cancel();
    _connectSub = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen((update) {
          if (update.connectionState == DeviceConnectionState.connected) {
            _connectedDeviceId = deviceId;
            _statusController.add('connected');
            _subscribeToNotifications(deviceId);
          } else if (update.connectionState ==
              DeviceConnectionState.disconnected) {
            _connectedDeviceId = null;
            _statusController.add('disconnected');
            _notifySub?.cancel();
          }
        });
  }

  void _subscribeToNotifications(String deviceId) {
    final char = QualifiedCharacteristic(
      serviceId: Uuid.parse(_serviceUuid),
      characteristicId: Uuid.parse(_charUuid),
      deviceId: deviceId,
    );
    _notifySub?.cancel();
    _notifySub = _ble.subscribeToCharacteristic(char).listen((bytes) {
      final text = utf8
          .decode(bytes, allowMalformed: true)
          .replaceAll('\u0000', '')
          .trim();
      if (text.isNotEmpty) _dataController.add(text);
    });
  }

  Future<void> disconnect() async {
    _notifySub?.cancel();
    _connectSub?.cancel();
    _connectedDeviceId = null;
    _statusController.add('disconnected');
  }

  void dispose() {
    _scanSub?.cancel();
    _connectSub?.cancel();
    _notifySub?.cancel();
    _dataController.close();
    _statusController.close();
    _devicesController.close();
  }
}

// =========================================================
//  BACKWARD COMPATIBILITY ALIAS (Untuk migrasi code)
// =========================================================
typedef BluetoothClassicService = BlindspotBleService;

// =========================================================
//  BLE SERVICE (untuk Fatigue Monitor - ESP32 BLE)
// =========================================================
class BleService {
  static const String _serviceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String _charUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';

  final _ble = FlutterReactiveBle();
  final _dataController = StreamController<String>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  final _devicesController = StreamController<DiscoveredDevice>.broadcast();

  StreamSubscription? _scanSub;
  StreamSubscription? _connectSub;
  StreamSubscription? _notifySub;
  String? _connectedDeviceId;

  Stream<String> get dataStream => _dataController.stream;
  Stream<String> get statusStream => _statusController.stream;
  Stream<DiscoveredDevice> get devicesStream => _devicesController.stream;
  bool get isConnected => _connectedDeviceId != null;

  void startScan() {
    _statusController.add('scanning');
    _scanSub?.cancel();
    _scanSub = _ble
        .scanForDevices(
          withServices: [Uuid.parse(_serviceUuid)],
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (device) {
            _devicesController.add(device);
          },
          onError: (e) {
            _statusController.add('scan_error: $e');
          },
        );
  }

  void stopScan() => _scanSub?.cancel();

  Future<void> connect(String deviceId) async {
    _statusController.add('connecting');
    _connectSub?.cancel();
    _connectSub = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen((update) {
          if (update.connectionState == DeviceConnectionState.connected) {
            _connectedDeviceId = deviceId;
            _statusController.add('connected');
            _subscribeToNotifications(deviceId);
          } else if (update.connectionState ==
              DeviceConnectionState.disconnected) {
            _connectedDeviceId = null;
            _statusController.add('disconnected');
            _notifySub?.cancel();
          }
        });
  }

  void _subscribeToNotifications(String deviceId) {
    final char = QualifiedCharacteristic(
      serviceId: Uuid.parse(_serviceUuid),
      characteristicId: Uuid.parse(_charUuid),
      deviceId: deviceId,
    );
    _notifySub?.cancel();
    _notifySub = _ble.subscribeToCharacteristic(char).listen((bytes) {
      final text = utf8
          .decode(bytes, allowMalformed: true)
          .replaceAll('\u0000', '')
          .trim();
      if (text.isNotEmpty) _dataController.add(text);
    });
  }

  Future<void> disconnect() async {
    _notifySub?.cancel();
    _connectSub?.cancel();
    _connectedDeviceId = null;
    _statusController.add('disconnected');
  }

  void dispose() {
    _scanSub?.cancel();
    _connectSub?.cancel();
    _notifySub?.cancel();
    _dataController.close();
    _statusController.close();
    _devicesController.close();
  }
}
