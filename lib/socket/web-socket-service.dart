import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/alerts.dart';

// // WebSocket service
// class WebSocketService extends ChangeNotifier {
//   WebSocketChannel? _channel;
//   bool _isConnected = false;
//   List<Alert> _alerts = [];
//   Map<String, int> _scoreboard = {};
//   String _connectionStatus = 'Disconnected';
//   String? _serverUrl;
//
//   bool get isConnected => _isConnected;
//
//   List<Alert> get alerts => List.from(_alerts);
//
//   Map<String, int> get scoreboard => Map.from(_scoreboard);
//
//   String get connectionStatus => _connectionStatus;
//
//   void connect(String serverUrl) {
//     try {
//       _serverUrl = serverUrl;
//       _channel = WebSocketChannel.connect(
//         Uri.parse('ws://$serverUrl/ws/video'),
//       );
//       _isConnected = true;
//       _connectionStatus = 'Connecting...';
//       notifyListeners();
//
//       _channel!.stream.listen(
//         _onMessage,
//         onError: _onError,
//         onDone: _onDisconnected,
//       );
//       _startPingTimer();
//     } catch (e) {
//       _onError(e);
//     }
//   }
//
//   bool _isExamOn = false;
//
//   bool get isExamOn => _isExamOn;
//
//   void startExam(String serverUrl) {
//     if (_channel != null) return;
//
//     _channel = WebSocketChannel.connect(Uri.parse('ws://$serverUrl/ws'));
//
//     _channel!.stream.listen(
//       _onMessage,
//       onError: (error) {
//         print("WebSocket error: $error");
//         _isExamOn = false;
//         notifyListeners();
//       },
//       onDone: () {
//         print("WebSocket closed");
//         _isExamOn = false;
//         notifyListeners();
//       },
//     );
//
//     _channel!.sink.add(jsonEncode({"type": "start_exam"}));
//
//     _isExamOn = true;
//     notifyListeners();
//   }
//
//   void stopExam() {
//     if (_channel == null) return;
//
//     _channel!.sink.add(jsonEncode({"type": "stop_exam"}));
//     _channel!.sink.close();
//
//     _channel = null;
//     _isExamOn = false;
//     notifyListeners();
//   }
//
//   void _onMessage(dynamic message) {
//     try {
//       final data = jsonDecode(message);
//       final messageType = data['type'];
//
//       switch (messageType) {
//         case 'connection':
//           _connectionStatus = 'Connected';
//           print('Connected to server: ${data['message']}');
//           break;
//
//         case 'alert':
//           final alert = Alert.fromJson(data);
//           _alerts.add(alert);
//
//           if (_alerts.length > 50) {
//             _alerts.removeAt(0);
//           }
//
//           print('New alert: ${alert.pid} - ${alert.reason}');
//           break;
//
//         case 'scoreboard':
//           _scoreboard = Map<String, int>.from(data['data']);
//           print('Scoreboard updated: $_scoreboard');
//           break;
//
//         case 'status':
//           print('Status update: ${data['message'] ?? data}');
//           break;
//
//         case 'pong':
//           break;
//
//         default:
//           print('Unknown message type: $messageType');
//       }
//
//       notifyListeners();
//     } catch (e) {
//       print('Error parsing message: $e');
//     }
//   }
//
//   void _onError(error) {
//     print('WebSocket error: $error');
//     _isConnected = false;
//     _connectionStatus = 'Error: $error';
//     notifyListeners();
//
//     Future.delayed(const Duration(seconds: 5), () {
//       if (_serverUrl != null) {
//         connect(_serverUrl!);
//       }
//     });
//   }
//
//   void _onDisconnected() {
//     print('WebSocket disconnected');
//     _isConnected = false;
//     _connectionStatus = 'Disconnected';
//     notifyListeners();
//   }
//
//   void _startPingTimer() {
//     Timer.periodic(const Duration(seconds: 30), (timer) {
//       if (_isConnected && _channel != null) {
//         try {
//           _channel!.sink.add(jsonEncode({'type': 'ping'}));
//         } catch (e) {
//           timer.cancel();
//         }
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   void disconnect() {
//     _channel?.sink.close(status.goingAway);
//     _isConnected = false;
//     _connectionStatus = 'Disconnected';
//     notifyListeners();
//   }
//
//   void clearAlerts() {
//     _alerts.clear();
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     disconnect();
//     super.dispose();
//   }
// }
