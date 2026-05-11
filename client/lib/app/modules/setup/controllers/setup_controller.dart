import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';

class SetupController extends GetxController {
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String charUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  final isScanning = false.obs;
  final isConnecting = false.obs;
  final setupDone = false.obs;
  final setupStatus = "".obs;
  final foundDevices = <ScanResult>[].obs;

  // Controllers for the UI
  final ssidController = TextEditingController();
  final passController = TextEditingController();
  final ipController = TextEditingController();

  BluetoothDevice? _connected;
  StreamSubscription? _scanSub;

  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
    _fetchNetworkInfo();
  }

  @override
  void onClose() {
    _scanSub?.cancel();
    _connected?.disconnect();
    ssidController.dispose();
    passController.dispose();
    ipController.dispose();
    super.onClose();
  }

  Future<void> _fetchNetworkInfo() async {
    try {
      // 1. Get the connected WiFi SSID (Works on iOS/Android/Windows. On macOS, Apple blocks this without Location Services)
      if (!Platform.isMacOS) {
        String? wifiName = await NetworkInfo().getWifiName();
        if (wifiName != null && wifiName.isNotEmpty) {
          ssidController.text = wifiName.replaceAll('"', '');
        }
      }

      // 2. Get the computer's local IP address
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            // Pick a typical local IPv4
            if (addr.address.startsWith('192.168.') ||
                addr.address.startsWith('10.') ||
                addr.address.startsWith('172.')) {
              ipController.text = addr.address;
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Could not fetch network info: $e");
    }
  }

  Future<void> _requestPermissions() async {
    // macOS handles Bluetooth permissions natively.
    // Calling permission_handler on macOS throws MissingPluginException.
    if (Platform.isMacOS) return;

    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> startScan() async {
    if (isScanning.value) return;
    foundDevices.clear();
    setupStatus.value = "Scanning for AirDrum sticks…";
    isScanning.value = true;

    await FlutterBluePlus.stopScan();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));

    _scanSub = FlutterBluePlus.onScanResults.listen((results) {
      for (final r in results) {
        if (r.device.platformName.contains("AirDrum") &&
            !foundDevices.any((d) => d.device.remoteId == r.device.remoteId)) {
          foundDevices.add(r);
        }
      }
    });

    await Future.delayed(const Duration(seconds: 6));
    await FlutterBluePlus.stopScan();
    _scanSub?.cancel();
    isScanning.value = false;

    if (foundDevices.isEmpty) {
      setupStatus.value =
          "No sticks found.\nMake sure the stick is powered on and nearby.";
    } else {
      setupStatus.value =
          "Found ${foundDevices.length} stick(s). Tap one to configure.";
    }
  }

  // ── Configure ─────────────────────────────────────────────────────────────

  Future<void> configureStick(BluetoothDevice device) async {
    final ssid = ssidController.text.trim();
    final pass = passController.text;
    final ip = ipController.text.trim();

    if (ssid.isEmpty || ip.isEmpty) {
      setupStatus.value = "Please fill in WiFi name and Computer IP first.";
      return;
    }

    isConnecting.value = true;
    setupStatus.value = "Connecting to ${device.platformName}…";

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connected = device;
      setupStatus.value = "Connected. Discovering services…";

      final services = await device.discoverServices();
      BluetoothCharacteristic? targetChar;

      for (final svc in services) {
        if (svc.uuid.toString().toLowerCase() == serviceUuid) {
          for (final c in svc.characteristics) {
            if (c.uuid.toString().toLowerCase() == charUuid) {
              targetChar = c;
              break;
            }
          }
        }
        if (targetChar != null) break;
      }

      if (targetChar == null) {
        setupStatus.value = "AirDrum service not found on device.";
        await device.disconnect();
        return;
      }

      setupStatus.value = "Sending credentials…";
      final payload = "$ssid,$pass,$ip";
      await targetChar.write(utf8.encode(payload), withoutResponse: false);

      setupStatus.value =
          "✅ Done! The stick is saving settings and rebooting.\n"
          "It will connect to '$ssid' automatically.";
      setupDone.value = true;

      await Future.delayed(const Duration(seconds: 2));
      await device.disconnect();
    } on FlutterBluePlusException catch (e) {
      setupStatus.value = "BLE Error: ${e.description}";
    } catch (e) {
      setupStatus.value = "Error: $e";
    } finally {
      isConnecting.value = false;
      _connected = null;
    }
  }
}
