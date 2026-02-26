import 'dart:io';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:async';
import '../../utils/logger.dart';

class UdpService extends GetxService {
  RawDatagramSocket? _socket;

  // Expose messages as a stream for controllers to listen
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

  @override
  void onInit() {
    super.onInit();
    _initUdp();
  }

  Future<void> _initUdp() async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5000);
      _socket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _socket?.receive();
          if (datagram != null) {
            String message = utf8.decode(datagram.data);
            _messageController.add(message);
          }
        }
      });
      Log.success('✅ UDP Service listening on port 5000', 'UDP');
    } catch (e, stackTrace) {
      Log.error('❌ Failed to start UDP Service: $e', e, stackTrace);
    }
  }

  @override
  void onClose() {
    _socket?.close();
    _messageController.close();
    super.onClose();
  }
}
