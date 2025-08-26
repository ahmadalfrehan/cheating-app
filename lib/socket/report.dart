import 'package:cheating_detection/getx/controller.dart';
import 'package:cheating_detection/widgets/alert-card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/alerts.dart';

class PostExamReviewScreen extends StatefulWidget {
  final List<Alert> alertScreenshots; // Pass screenshots as byte data

  const PostExamReviewScreen({Key? key, required this.alertScreenshots})
    : super(key: key);

  @override
  State<PostExamReviewScreen> createState() => _PostExamReviewScreenState();
}

class _PostExamReviewScreenState extends State<PostExamReviewScreen> {
  final controller = Get.put(AppController());

  @override
  void initState() {
    super.initState();
    controller.alerts.value = widget.alertScreenshots;
    controller.alertScreenshotslength.value = widget.alertScreenshots.length;
    controller.genControllers();
  }

  @override
  void dispose() {
    // for (var controller in _controllers) {
    //   controller.dispose();
    // }
    super.dispose();
  }

  IconData _getAlertIcon(String reason) {
    switch (reason.toLowerCase()) {
      case 'hand_movement':
      case 'hand movement':
        return Icons.pan_tool;
      case 'standing':
        return Icons.accessibility;
      case 'head_turn':
      case 'head':
        return Icons.face;
      case 'horizontal_movement':
        return Icons.swap_horiz;
      case 'disappear':
        return Icons.visibility_off;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Exam Report Review", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.alertScreenshots.length,
        itemBuilder: (context, index) {
          return AlertCard(
            alert: widget.alertScreenshots[index],
            description: true,
            index: index,
            // controller: _controllers[index],
          );
        },
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child:
          Obx(() {
            print(controller.isLoading.value);
            return
              // !controller.isLoading.value ? LinearProgressIndicator() :

              ElevatedButton.icon(
                label: const Text(
                  "Send Results", style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.sendResultsMultipart,
              );
          }
          )
      ),
    );
  }
}
