import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_channel/web_socket_channel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String streamUrl = 'http://127.0.0.1:8000/video_feed';
  final String wsUrl = 'ws://127.0.0.1:8000/ws';
  late WebSocketChannel channel;
  List<String> alerts = [];

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    channel.stream.listen(
      (data) {
        print("🚨 Alert received: $data");

        setState(() {
          alerts.insert(0, data);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("ALERT: $data")));
      },
      onError: (err) {
        print("WebSocket Error: $err");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("WebSocket Error: $err")));
      },
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OpenPose Live Stream')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 350,
              child: Mjpeg(
                stream: streamUrl,
                isLive: true,
                error: (context, error, stack) => Text('Stream error: $error'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 150,
              // width: 150,
              child: Image.network(
                'https://ahmadalfrehan.github.io/assets/assets/images/logo.jpg',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                height: 250,
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        Text(alerts[index]),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MaterialButton(
                              child: Text(
                                'Process',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () {},
                            ),
                            MaterialButton(
                              child: Text('Ignore'),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
