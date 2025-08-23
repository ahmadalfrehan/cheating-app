import 'package:cheating_detection/screens/classes.dart';
import 'package:cheating_detection/screens/live-openposev2.dart';
import 'package:cheating_detection/screens/login-screen.dart';
import 'package:cheating_detection/screens/signup-screen.dart';
import 'package:cheating_detection/socket/app.dart';
import 'package:cheating_detection/socket/start.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final box = GetStorage();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final token = box.read('auth_token');
    print(token);
    return GetMaterialApp(
      title: 'OpenPose MJPEG Stream',
      debugShowCheckedModeBanner: false,
      initialRoute: token != null ? '/classes' : '/login',
      routes: {
        '/classes': (context) => Classes(),
        '/ext': (context) => CheatingDetectionApp(),
        '/start': (context) => Start(),
        '/exam': (context) => ExamMonitoringApp(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}

//
// class HOME extends StatefulWidget {
//   const HOME({super.key});
//
//   @override
//   State<HOME> createState() => _HOMEState();
// }
//
// class _HOMEState extends State<HOME> {
//   final String streamUrl = 'http://192.168.176.143:5000/video_feed';
//
//   late IO.Socket socket;
//
//   @override
//   void initState() {
//     socket = IO.io('http://192.168.176.143:5000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });
//
//     socket.onConnect((_) {
//       print('Connected to server');
//     });
//
//     socket.on('hand_alert', (data) {
//       print('New hand alert: $data');
//       // You can update the UI here or use setState() to reflect changes.
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     socket.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('OpenPose Live Stream')),
//       body: Center(
//         child: Mjpeg(
//           stream: streamUrl,
//           isLive: true,
//           error: (context, error, stack) => Text('Stream error: $error'),
//         ),
//       ),
//     );
//   }
// }
