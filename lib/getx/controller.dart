import 'dart:convert';
import 'dart:io';

// import 'package:dio/dio.dart'as dio;

import 'package:cheating_detection/models/alerts.dart';
import 'package:dio/dio.dart' as di;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user-cache.dart';
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
  final RxBool isLoadingSend = false.obs;
  final RxInt classroomId = 0.obs;
  final RxInt alertScreenshotslength = 0.obs;
  final RxList<Alert> alerts = <Alert>[].obs; //Alert.name().obs; //.obs;
  List<TextEditingController> controllers = <TextEditingController>[];

  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController periodH = TextEditingController();
  TextEditingController periodM = TextEditingController();

  final RxBool isExamOn = false.obs;
  final RxString examId = '1'.obs;
  final TextEditingController serverController = TextEditingController(
    text: '192.168.0.0:8000',
  );
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

      print(token.value);
      final userName = data['data']["user"]["name"];
      final userEmail = data['data']["user"]["email"];


      UserCache.saveUser(userName, userEmail);


      print(UserCache.name);
      print(UserCache.email);

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
    UserCache.clearUser();
    Get.offAll(() => LoginScreen());
  }

  void genControllers() {
    controllers = List.generate(
      alertScreenshotslength.value,
      (_) => TextEditingController(),
    );
  }

  createExam() async {
    try {
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
    examId.value = data['data']['id'].toString();
    if (data['status'] == true) {
      Get.toNamed('/ext');
    }

    isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      print(error);
    }
  }

  Future<void> uploadFromLocalServer(String localUrl) async {

  }

  getImage(url) async {
    final localResponse = await http.get(Uri.parse(url));
    if (localResponse.statusCode != 200) {
      print("Failed to fetch image from local server");
    }
    final screenshotBase64 = base64Encode(localResponse.bodyBytes);

    return screenshotBase64;
  }
  void sendResults() async {
    final results = alerts.value;



    final body = jsonEncode({
      "exam_id": examId.value,
      "alerts":
      [
        {
          "title": "test",
          "risk": "high",
          "description": "testttt",
          "student_id": "ID3",
          "time": "2025-08-23 14:45:00",
          "screenshot": await getImage(
              'http://127.0.0.1:8000/alerts/alert_ID_1_hand_1.jpg')
        }
      ]
    });


    final response = await http.post(
      Uri.parse('${API_URL}store-alerts'), body: body,
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


  String getFilenameFromUrl(String url) {
    return url
        .split('/')
        .last; // e.g. alert_ID_2_head_0.jpg
  }

  //
  // final dio = Dio();
  //
  // Future<String> saveToDownloads(List<int> bytes, String filename) async {
  //   // Get the downloads directory
  //   // final downloadsDirectory = await // DownloadsPathProvider.downloadsDirectory;
  //   final file = File("/storage/emulated/0/download/$filename");
  //
  //
  //   await file.writeAsBytes(bytes);
  //
  //   return file.path;
  // }
  // convertScreensAlerts() async {
  //   List<Map<String, dynamic>> alertsData = [];
  //   for (var alert in alerts) {
  //     String alertScreenShot = 'http://${serverController.text}/${alert
  //         .screenshotUrl}';
  //     print(alertScreenShot);
  //     var localResponse = null;
  //     var screenshotFile = null;
  //     try {
  //       localResponse = await dio.get<List<int>>(
  //         alertScreenShot,
  //         options: Options(responseType: ResponseType.bytes),
  //       );
  //       final localPath = await saveToDownloads(
  //         localResponse.data!,
  //         // "${alert.pid}_${alert.timestamp}.jpg",
  //         alertScreenShot,
  //       );
  //
  //     screenshotFile = di.MultipartFile.fromBytes(
  //       localResponse.data!,
  //       // filename: "${alert.pid}_${alert.timestamp}.jpg",
  //       filename: alertScreenShot,
  //       // give each a unique name
  //       contentType: MediaType("image", "jpeg"), //
  //     );
  //
  //     } catch (error) {
  //       print(error);
  //     }
  //     //
  //
  //     alertsData.add({
  //       "title": alert.reason ?? '',
  //       "risk": alert.risk == '' ? 'low' : alert.risk,
  //       "description": alert.description,
  //       "student_id": alert.pid,
  //       "time": alert.dateTime.toLocal().toString().split('.')[0],
  //       if(screenshotFile != null)
  //         "screenshot": await screenshotFile,
  //     });
  //   }
  //   return alertsData;
  // }
  //
  // Future<void> sendResultsMultipart() async {
  //
  //   isLoading.value = true;
  //   List<Map<String, dynamic>> alertsData = [];
  //   alertsData = await convertScreensAlerts();
  //   final formData = di.FormData.fromMap({
  //     "exam_id": examId.value.toString(),
  //     'alerts': alertsData
  //   });
  //   print(alertsData);
  //   final response = await dio.post(
  //     "${API_URL}store-alerts",
  //     data: formData,
  //     options: Options(headers: {
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer ${token.value}',
  //     },
  //       validateStatus: (status) {
  //         return status != null && status < 500;
  //       },),
  //   );
  //
  //   print(response.statusCode);
  //   print(response.data);
  //
  //   Get.showSnackbar(
  //     GetSnackBar(
  //       title: "Success",
  //       message: "Results sent successfully!",
  //       duration: Duration(seconds: 2),
  //       snackPosition: SnackPosition.BOTTOM,
  //       // or SnackPosition.TOP
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  //   // Get.toNamed('/classes');
  //   isLoading.value = false;
  // }





  final dio = Dio();

  Future<String> saveToDownloads(List<int> bytes, String filename) async {
    final file = File("/storage/emulated/0/download/$filename");
    await file.writeAsBytes(bytes);
    return file.path;
  }

  convertScreensAlerts() async {
    List<Map<String, dynamic>> alertsData = [];

    for (var alert in alerts) {
      String alertScreenShot = 'http://${serverController.text}/${alert
          .screenshotUrl}';
      print('Attempting to download: $alertScreenShot');

      di.MultipartFile? screenshotFile;

      try {
        final fileName = alertScreenShot
            .split('/')
            .last
            .toLowerCase();
        if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
          var localResponse = await dio.get<List<int>>(
            alertScreenShot,
            options: Options(responseType: ResponseType.bytes),
          );


          if (localResponse.data != null &&
              localResponse.data!.isNotEmpty &&
              localResponse.statusCode == 200) {
            String filename = "${alert.pid}_${alert.timestamp}.jpg";
            await saveToDownloads(localResponse.data!, filename);

            screenshotFile = di.MultipartFile.fromBytes(
              localResponse.data!,
              filename: filename,
              contentType: MediaType("image", "jpeg"),
            );
            print('✓ Screenshot downloaded successfully for ${alert.pid}');
          } else {
            print('✗ No valid image data received for ${alert.pid}');
            screenshotFile = null;
          }
        } else {
          print("⚠️ Skipping non-JPG screenshot: $alertScreenShot");
        }
      } catch (error) {
        print('✗ Error downloading screenshot for ${alert.pid}: $error');
        screenshotFile = null;
      }


      Map<String, dynamic> alertData = {
        "title": alert.reason ?? '',
        "risk": alert.risk == '' ? 'low' : alert.risk,
        "description": alert.description,
        "student_id": alert.pid,
        "time": alert.dateTime.toLocal().toString().split('.')[0],
      };


      if (screenshotFile != null) {
        alertData["screenshot_file"] = screenshotFile;
      }

      alertsData.add(alertData);
    }

    return alertsData;
  }

  Future<void> sendResultsMultipart() async {
    isLoadingSend.value = true;
    try {
      List<Map<String, dynamic>> alertsData = await convertScreensAlerts();


      Map<String, dynamic> formDataMap = {
        "exam_id": examId.value.toString(),
      };


      for (int i = 0; i < alertsData.length; i++) {
        var alert = alertsData[i];

        formDataMap["alerts[$i][title]"] = alert["title"];
        formDataMap["alerts[$i][risk]"] = alert["risk"];
        formDataMap["alerts[$i][description]"] = alert["description"];
        formDataMap["alerts[$i][student_id]"] = alert["student_id"];
        formDataMap["alerts[$i][time]"] = alert["time"];

        // Only add screenshot field if we have a valid MultipartFile
        if (alert["screenshot_file"] != null &&
            alert["screenshot_file"] is di.MultipartFile) {
          formDataMap["alerts[$i][screenshot]"] = alert["screenshot_file"];
          print('Added screenshot for alert $i');
        } else {
          print('No screenshot available for alert $i');
        }
      }

      final formData = di.FormData.fromMap(formDataMap);

      print('Sending ${alertsData.length} alerts with screenshots');

      final response = await dio.post(
        "${API_URL}store-alerts",
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${token.value}',
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoadingSend.value = false;
        // Get.offAllNamed('/classes');
        // Get.put(AppController());
        Get.showSnackbar(
          GetSnackBar(
            title: "Success",
            message: "Results sent successfully!",
            duration: Duration(seconds: 2),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
          ),
        );

      } else {
        print('Upload failed with status: ${response.statusCode}');
        Get.showSnackbar(
          GetSnackBar(
            title: "Error",
            message: "Upload failed: ${response.data}",
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      isLoadingSend.value = false;
      print('Error sending results: $error');
      Get.showSnackbar(
        GetSnackBar(
          title: "Error",
          message: "Failed to send results: $error",
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        ),
      );
    }

    isLoadingSend.value = false;
  }


}
