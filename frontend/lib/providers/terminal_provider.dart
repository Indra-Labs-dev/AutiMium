import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class TerminalProvider extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String _wsUrl = 'ws://localhost:8000/ws/terminal';
  List<TerminalMessage> _messages = [];
  String _sessionId = '';

  bool get isConnected => _isConnected;
  List<TerminalMessage> get messages => List.unmodifiable(_messages);
  String get sessionId => _sessionId;

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _isConnected = true;
      _messages.clear();
      
      // Listen for messages
      _channel!.stream.listen(
        (message) {
          final data = json.decode(message as String);
          final terminalMessage = TerminalMessage.fromJson(data);
          _messages.add(terminalMessage);
          
          if (terminalMessage.type == 'start') {
            _sessionId = terminalMessage.sessionId ?? '';
          }
          
          notifyListeners();
        },
        onError: (error) {
          _isConnected = false;
          _messages.add(TerminalMessage(
            type: 'error',
            data: null,
            error: 'Connection error: $error',
            sessionId: null,
          ));
          notifyListeners();
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
        },
      );
      
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _messages.add(TerminalMessage(
        type: 'error',
        data: null,
        error: 'Failed to connect: $e',
        sessionId: null,
      ));
      notifyListeners();
    }
  }

  void sendCommand(String command) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(json.encode({'command': command}));
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

class TerminalMessage {
  final String type;
  final String? data;
  final String? error;
  final String? sessionId;
  final int? returnCode;

  TerminalMessage({
    required this.type,
    this.data,
    this.error,
    this.sessionId,
    this.returnCode,
  });

  factory TerminalMessage.fromJson(Map<String, dynamic> json) {
    return TerminalMessage(
      type: json['type'] ?? 'unknown',
      data: json['data'],
      error: json['error'],
      sessionId: json['session_id'],
      returnCode: json['returncode'],
    );
  }

  @override
  String toString() {
    return 'TerminalMessage(type: $type, data: $data, error: $error, sessionId: $sessionId, returnCode: $returnCode)';
  }
}
