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


