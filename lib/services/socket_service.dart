import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService with ChangeNotifier, WidgetsBindingObserver {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IOWebSocketChannel? _channel;
  final String socketUrl = "ws://192.168.192.252:5000"; // ✅ WebSocket URL
  final StreamController<Map<String, bool>> _availabilityController =
      StreamController.broadcast();

  Stream<Map<String, bool>> get availabilityStream =>
      _availabilityController.stream;

  bool _isConnected = false;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    connectToWebSocket();
  }

  void connectToWebSocket() {
    if (_isConnected) return;

    try {
      print("🔌 Connecting to WebSocket...");
      _channel = IOWebSocketChannel.connect(socketUrl);
      _isConnected = true;
      notifyListeners();

      _channel!.stream.listen(
        (message) {
          print("📩 Received: $message");
          // ✅ Handle doctor availability updates here
        },
        onDone: () {
          print("❌ WebSocket Disconnected!");
          _isConnected = false;
          notifyListeners();
          attemptReconnect();
        },
        onError: (error) {
          print("⚠️ WebSocket Error: $error");
          _isConnected = false;
          notifyListeners();
          attemptReconnect();
        },
      );
    } catch (e) {
      print("❌ WebSocket Error: $e");
      _isConnected = false;
      notifyListeners();
      attemptReconnect();
    }
  }

  void disconnect() {
    print("🔌 Disconnecting WebSocket...");
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  void attemptReconnect() {
    Future.delayed(Duration(seconds: 5), () {
      if (!_isConnected) {
        print("🔄 Attempting to reconnect...");
        connectToWebSocket();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("🔄 App Resumed - Checking WebSocket...");
      if (!_isConnected) {
        connectToWebSocket();
      }
    }
  }

  // ❌ REMOVE dispose() to keep WebSocket alive
}
