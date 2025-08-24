import 'dart:convert';
import 'dart:io';

import 'package:cheating_detection/models/alerts.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../screens/classes.dart';
import '../screens/login-screen.dart';

class AppController extends GetxController {
  final String API_URL = 'https://observeai.bazaar963.com/api/';
  final box = GetStorage();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final RxBool isLogging = false.obs;
  final RxBool isLoading = false.obs;
  final RxInt classroomId = 0.obs;
  final RxInt alertScreenshotslength = 0.obs;
  final RxList<Alert> alerts = <Alert>[].obs; //Alert.name().obs; //.obs;
  List<TextEditingController> controllers = <TextEditingController>[];

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController periodH = TextEditingController();
  TextEditingController periodM = TextEditingController();

  final RxBool isExamOn = false.obs;
  var classesResponse =
      ClassesResponse(
        status: false,
        message: "",
        data: ClassesData(numberOfActiveClasses: 0, classes: []),
      ).obs;

  // String
  RxString token = ''.obs;

  @override
  onInit() {
    super.onInit();
    token.value = box.read('auth_token')??"";
    getHome();
  }

  getHome() async {
    isLoading.value = true;
    print(Uri.parse('${API_URL}home-page'));
    final response = await http.get(
      Uri.parse('${API_URL}home-page'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${token.value}',
      },
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      classesResponse.value = ClassesResponse.fromRawJson(response.body);

      print("Status: ${classesResponse.value.status}");
      print("Message: ${classesResponse.value.message}");
      print(
        "Active Classes Count: ${classesResponse.value.data.numberOfActiveClasses}",
      );

      for (var classItem in classesResponse.value.data.classes) {
        print("Class: ${classItem.name}, Capacity: ${classItem.capacity}");
      }
    }
    isLoading.value = false;
  }

  performLogin() async {
    try {
      isLogging.value = true;
      print(Uri.parse('${API_URL}login'));
      print({'email': email.text, 'password': password.text});
      final response = await http.post(
        Uri.parse('${API_URL}login'),
        body: {'email': email.text, 'password': password.text},
        headers: {'Accept': 'application/json'},
      );
      print(response.body);
      print(response.statusCode);
      final data = json.decode(response.body);
      token.value = data['data']['token'];
      // response.body['data']['token'];
      print(token.value);
      saveToken(token.value);

      isLogging.value = false;
      if (token.value != '') {
        Get.offAll(() => Classes());
      }
    } catch (error) {
      isLogging.value = false;
      print(error);
    }
  }

  void saveToken(String token) {
    box.write('auth_token', token);
  }

  void logout() {
    box.remove('auth_token');
    Get.offAll(() => LoginScreen());
  }

  void genControllers() {
    controllers = List.generate(
      alertScreenshotslength.value,
      (_) => TextEditingController(),
    );
  }

  createExam() async {
    // try {
    isLoading.value = true;
    print({
      "classroom_id": classroomId.value.toString(),
      "title": title.text,
      "period": periodM.text,
      "description": description.text,
    });
    print(Uri.parse('${API_URL}create-exam'));
    final response = await http.post(
      Uri.parse('${API_URL}create-exam'),
      body: {
        "classroom_id": classroomId.value.toString(),
        "title": title.text,
        "period": periodM.text,
        "description": description.text,
      },
      headers: {
        'Accept': 'application/json',

        'Authorization': 'Bearer ${token.value}',
      },
    );
    print(response.body);
      print(response.statusCode);
      final data = json.decode(response.body);
      print(data);
    if (data['status'] == true) {
      Get.toNamed('/ext');
    }

    isLoading.value = false;
    // } catch (error) {
    //   isLoading.value = false;
    //   print(error);
    // }
  }


// Convert file to base64
//   Future<String> fileToBase64(String filePath) async {
//     final bytes = await File(filePath).readAsBytes();
//     return base64Encode(bytes);
//   }
  void sendResults() async {
    final results = alerts.value;

    // final screenshotBase64 = await fileToBase64("path/to/screenshot.png");


    final response = await http.post(Uri.parse('${API_URL}store-alerts')
       , body: jsonEncode({
        "exam_id": "3",
        "alerts": [
          {
            "title": "test",
            "risk": "high",
            "description": "testttt",
            "student_id": "ID3",
            "time": "2025-08-23 14:45:00",
            // "screenshot":await File('')
          }
        ]
      }),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json', // <-- IMPORTANT
        'Authorization': 'Bearer ${token.value}',
      },
    );
    print(response.body);
    print(response.statusCode);
    final data = json.decode(response.body);
    print(data);


    print("Sending results: $results");
    for (var o in alerts.value) {
      print(o.reason);
      print(o.description);
      print(o.screenshotUrl);
      print(o.timestamp);
      print(o.pid);
    }

    GetSnackBar(title: "Results sent successfully!");
  }
}
