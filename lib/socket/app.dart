import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cheating_detection/socket/report.dart';
// import 'package:cheating_detection/socket/web-socket-service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../getx/controller.dart';
import '../models/alerts.dart';
import '../widgets/alert-card.dart';

// WebSocket service
class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  List<Alert> _alerts = [];
  Map<String, int> _scoreboard = {};
  String _connectionStatus = 'Disconnected';
  String? _serverUrl;

  bool get isConnected => _isConnected;

  List<Alert> get alerts => List.from(_alerts);

  Map<String, int> get scoreboard => Map.from(_scoreboard);

  String get connectionStatus => _connectionStatus;

  void connect(String serverUrl) {
    try {
      _serverUrl = serverUrl;
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$serverUrl/ws/video'),
      );
      _isConnected = true;
      _connectionStatus = 'Connecting...';
      notifyListeners();

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
      );
      _startPingTimer();
    } catch (e) {
      _onError(e);
    }
  }

  bool _isExamOn = false;

  bool get isExamOn => _isExamOn;

  void startExam(String serverUrl) {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(Uri.parse('ws://$serverUrl/ws'));

    _channel!.stream.listen(
      _onMessage,
      onError: (error) {
        print("WebSocket error: $error");
        _isExamOn = false;
        notifyListeners();
      },
      onDone: () {
        print("WebSocket closed");
        _isExamOn = false;
        notifyListeners();
      },
    );

    _channel!.sink.add(jsonEncode({"type": "start_exam"}));

    _isExamOn = true;
    notifyListeners();
  }

  void stopExam() {
    if (_channel == null) return;

    _channel!.sink.add(jsonEncode({"type": "stop_exam"}));
    _channel!.sink.close();

    _channel = null;
    _isExamOn = false;
    notifyListeners();
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final messageType = data['type'];

      switch (messageType) {
        case 'connection':
          _connectionStatus = 'Connected';
          print('Connected to server: ${data['message']}');
          break;

        case 'alert':
          final alert = Alert.fromJson(data);
          _alerts.add(alert);

          if (_alerts.length > 50) {
            _alerts.removeAt(0);
          }

          print('New alert: ${alert.pid} - ${alert.reason}');
          break;

        case 'scoreboard':
          _scoreboard = Map<String, int>.from(data['data']);
          print('Scoreboard updated: $_scoreboard');
          break;

        case 'status':
          print('Status update: ${data['message'] ?? data}');
          break;

        case 'pong':
          break;

        default:
          print('Unknown message type: $messageType');
      }

      notifyListeners();
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void _onError(error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _connectionStatus = 'Error: $error';
    if (!_disposed) notifyListeners(); // Only notify if not disposed
    // notifyListeners();

    Future.delayed(const Duration(seconds: 5), () {
      if (_serverUrl != null) {
        connect(_serverUrl!);
      }
    });
  }

  void _onDisconnected() {
    print('WebSocket disconnected');
    _isConnected = false;
    _connectionStatus = 'Disconnected';
    notifyListeners();
  }

  void _startPingTimer() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
    _connectionStatus = 'Disconnected';
    notifyListeners();
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    super.dispose();
  }
}

// Main app
class CheatingDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebSocketService()),
        ChangeNotifierProvider(
          create: (_) => VideoStreamService()..connect('127.0.0.1:8000'),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cheating Detection Monitor',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // appBar: AppBar(
        //   title: Text('Cheating Detection Monitor'),
        //   backgroundColor: Colors.blueGrey,
        // ),
        home: MonitorScreen(),
      ),
    );
  }
}

// Monitor screen
class MonitorScreen extends StatefulWidget {
  @override
  _MonitorScreenState createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {


  final controller = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    final videoService = Provider.of<VideoStreamService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cheating Detection Monitor',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<WebSocketService>(
        builder: (context, webSocketService, child) {
          return Column(
            children: [
              // Connection panel
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.serverController,
                            decoration: InputDecoration(
                              labelText: 'Server Address',
                              hintText: 'ip:port (e.g., 192.168.1.100:8000)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (webSocketService.isConnected) {
                              webSocketService.disconnect();
                              videoService.disconnect();
                              Get.to(
                                    () =>
                                    PostExamReviewScreen(
                                      alertScreenshots: webSocketService.alerts,
                                    ),
                              );
                              // alerts
                            } else {
                              webSocketService.connect(
                                  controller.serverController.text);
                              videoService.connect(
                                  controller.serverController.text);
                            }

                            // if (videoService.isConnected) {
                            //   videoService.disconnect();
                            // } else {

                            // }
                          },

                          onLongPress: () {
                            Get.to(
                                  () => PostExamReviewScreen(
                                alertScreenshots: webSocketService.alerts,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            webSocketService.isConnected
                                ? Colors.red
                                : Colors.green,
                          ),
                          child: Text(
                            webSocketService.isConnected
                                ? 'End Exam'
                                : 'Start Exam',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          webSocketService.isConnected
                              ? Icons.wifi
                              : Icons.wifi_off,
                          color:
                          webSocketService.isConnected
                              ? Colors.green
                              : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Status: ${webSocketService.connectionStatus}',
                          style: TextStyle(
                            color:
                            webSocketService.isConnected
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live OpenPose Detection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8), //rashwani123
                    videoService.currentFrame != null
                        ? Image.memory(
                      videoService.currentFrame!,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.low, // faster decode
                      isAntiAlias: false,
                    )
                        : Center(child: Text("Waiting for video...")),
                  ],
                ),
              ),

              // Scoreboard
              if (webSocketService.scoreboard.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scoreboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children:
                        webSocketService.scoreboard.entries.map((entry) {
                          return Chip(
                            label: Text('${entry.key}: ${entry.value}'),
                            backgroundColor:
                            entry.value >= 7
                                ? Colors.red[100]
                                : entry.value >= 4
                                ? Colors.orange[100]
                                : Colors.green[100],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              // Alerts list
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Alerts (${webSocketService.alerts.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          if (webSocketService.alerts.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                showAlertsModal(context, webSocketService);
                              },
                              child: Text('See All'),
                            ),

                          if (webSocketService.alerts.isNotEmpty)
                            TextButton(
                              onPressed: () => webSocketService.clearAlerts(),
                              child: Text('Clear All'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                      webSocketService.alerts.isEmpty
                          ? Center(
                        child: Text(
                          webSocketService.isConnected
                              ? 'No alerts yet'
                              : 'Connect to server to see alerts',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                          : ListView.builder(
                        itemCount: webSocketService.alerts.length,
                        reverse: true, // Show newest first
                        itemBuilder: (context, index) {
                          final alert =
                          webSocketService.alerts[webSocketService
                              .alerts
                              .length -
                              1 -
                              index];
                          return AlertCard(alert: alert);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void showAlertsModal(BuildContext context, WebSocketService webSocketService) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // allow full screen
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
          expand: true,
          builder: (context, scrollController) {
            return
              Consumer<WebSocketService>(
                builder: (context, webSocketService, child) {
                  return

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: Column(
                        children: [

                          Container(
                            width: 40,
                            height: 5,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Alerts (${webSocketService.alerts.length})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (webSocketService.alerts.isNotEmpty)
                                  TextButton(
                                    onPressed: () =>
                                        webSocketService.clearAlerts(),
                                    child: Text('Clear All'),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: webSocketService.alerts.isEmpty
                                ? Center(
                              child: Text(
                                webSocketService.isConnected
                                    ? 'No alerts yet'
                                    : 'Connect to server to see alerts',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                                : ListView.builder(
                              controller: scrollController,
                              itemCount: webSocketService.alerts.length,
                              reverse: true,
                              itemBuilder: (context, index) {
                                final alert = webSocketService
                                    .alerts[webSocketService.alerts.length - 1 -
                                    index];
                                return AlertCard(alert: alert);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                },
              );
          }
          );
    },
  );
}

class VideoStreamService extends ChangeNotifier {
  WebSocketChannel? _videoChannel;
  bool _isConnected = false;
  Uint8List? _currentFrame;
  String? _serverUrl;
  Timer? _pingTimer;

  bool get isConnected => _isConnected;

  Uint8List? get currentFrame => _currentFrame;

  void connect(String serverUrl) {
    try {
      _serverUrl = serverUrl;
      _videoChannel = WebSocketChannel.connect(
        Uri.parse('ws://$serverUrl/ws/video'),
      );
      _isConnected = true;
      notifyListeners();

      _videoChannel!.stream.listen(
        _onVideoMessage,
        onError: _onVideoError,
        onDone: _onVideoDisconnected,
      );

      // Start ping timer
      _startPingTimer();

      // Request initial frame
      _requestFrame();
    } catch (e) {
      _onVideoError(e);
    }
  }

  void _onVideoMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final messageType = data['type'];

      switch (messageType) {
        case 'connection':
          print('Video stream connected: ${data['message']}');
          break;

        case 'video_frame':
          final frameData = data['data'];
          if (frameData != null) {
            _currentFrame = base64Decode(frameData);
            notifyListeners();
          }
          break;

        case 'pong':
        // Handle pong response
          break;

        default:
          print('Unknown video message type: $messageType');
      }
    } catch (e) {
      print('Error parsing video message: $e');
    }
  }

  void _onVideoError(error) {
    print('Video WebSocket error: $error');
    _isConnected = false;
    // notifyListeners();
    if (!_disposed) notifyListeners(); // Only notify if not disposed

    // Try to reconnect after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_serverUrl != null) {
        connect(_serverUrl!);
      }
    });
  }

  void _onVideoDisconnected() {
    print('Video WebSocket disconnected');
    _isConnected = false;
    notifyListeners();
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isConnected && _videoChannel != null) {
        try {
          _videoChannel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  Timer? _frameRequestTimer;

  void _requestFrame() {
    _frameRequestTimer?.cancel();
    _frameRequestTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
        ) {
      if (_isConnected && _videoChannel != null) {
        try {
          _videoChannel!.sink.add(jsonEncode({'type': 'request_frame'}));
        } catch (e) {
          print('Error requesting frame: $e');
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
    //
    // if (_isConnected && _videoChannel != null) {
    //   try {
    //     _videoChannel!.sink.add(jsonEncode({'type': 'request_frame'}));
    //   } catch (e) {
    //     print('Error requesting frame: $e');
    //   }
    // }
  }

  void disconnect() {
    _pingTimer?.cancel();
    _videoChannel?.sink.close(status.goingAway);
    _isConnected = false;
    _currentFrame = null;
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    super.dispose();
  }
}
