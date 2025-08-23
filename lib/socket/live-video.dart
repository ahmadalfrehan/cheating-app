import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

// class VideoStreamService extends ChangeNotifier {
//   WebSocketChannel? _videoChannel;
//   bool _isConnected = false;
//   Uint8List? _currentFrame;
//   String? _serverUrl;
//   Timer? _pingTimer;
//
//   bool get isConnected => _isConnected;
//
//   Uint8List? get currentFrame => _currentFrame;
//
//   void connect(String serverUrl) {
//     try {
//       _serverUrl = serverUrl;
//       _videoChannel = WebSocketChannel.connect(
//         Uri.parse('ws://$serverUrl/ws/video'),
//       );
//       _isConnected = true;
//       notifyListeners();
//
//       _videoChannel!.stream.listen(
//         _onVideoMessage,
//         onError: _onVideoError,
//         onDone: _onVideoDisconnected,
//       );
//
//       // Start ping timer
//       _startPingTimer();
//
//       // Request initial frame
//       _requestFrame();
//     } catch (e) {
//       _onVideoError(e);
//     }
//   }
//
//   void _onVideoMessage(dynamic message) {
//     try {
//       final data = jsonDecode(message);
//       final messageType = data['type'];
//
//       switch (messageType) {
//         case 'connection':
//           print('Video stream connected: ${data['message']}');
//           break;
//
//         case 'video_frame':
//           final frameData = data['data'];
//           if (frameData != null) {
//             _currentFrame = base64Decode(frameData);
//             notifyListeners();
//           }
//           break;
//
//         case 'pong':
//           // Handle pong response
//           break;
//
//         default:
//           print('Unknown video message type: $messageType');
//       }
//     } catch (e) {
//       print('Error parsing video message: $e');
//     }
//   }
//
//   void _onVideoError(error) {
//     print('Video WebSocket error: $error');
//     _isConnected = false;
//     notifyListeners();
//
//     // Try to reconnect after 3 seconds
//     Future.delayed(const Duration(seconds: 3), () {
//       if (_serverUrl != null) {
//         connect(_serverUrl!);
//       }
//     });
//   }
//
//   void _onVideoDisconnected() {
//     print('Video WebSocket disconnected');
//     _isConnected = false;
//     notifyListeners();
//   }
//
//   void _startPingTimer() {
//     _pingTimer?.cancel();
//     _pingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
//       if (_isConnected && _videoChannel != null) {
//         try {
//           _videoChannel!.sink.add(jsonEncode({'type': 'ping'}));
//         } catch (e) {
//           timer.cancel();
//         }
//       } else {
//         timer.cancel();
//       }
//     });
//   }
//
//   Timer? _frameRequestTimer;
//
//   void _requestFrame() {
//     _frameRequestTimer?.cancel(); // prevent multiple timers
//     _frameRequestTimer = Timer.periodic(const Duration(milliseconds: 50), (
//       timer,
//     ) {
//       if (_isConnected && _videoChannel != null) {
//         try {
//           _videoChannel!.sink.add(jsonEncode({'type': 'request_frame'}));
//         } catch (e) {
//           print('Error requesting frame: $e');
//           timer.cancel();
//         }
//       } else {
//         timer.cancel();
//       }
//     });
//     //
//     // if (_isConnected && _videoChannel != null) {
//     //   try {
//     //     _videoChannel!.sink.add(jsonEncode({'type': 'request_frame'}));
//     //   } catch (e) {
//     //     print('Error requesting frame: $e');
//     //   }
//     // }
//   }
//
//   void disconnect() {
//     _pingTimer?.cancel();
//     _videoChannel?.sink.close(status.goingAway);
//     _isConnected = false;
//     _currentFrame = null;
//     notifyListeners();
//   }
//
//   @override
//   void dispose() {
//     disconnect();
//     super.dispose();
//   }
// }
