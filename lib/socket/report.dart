import 'dart:typed_data';

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
        title: const Text("Exam Report Review"),
        centerTitle: true,
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
          // return Card(
          //   margin: const EdgeInsets.symmetric(vertical: 8),
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //   elevation: 4,
          //   child: Padding(
          //     padding: const EdgeInsets.all(12.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text("Alert #${widget.alertScreenshots[index].reason}",
          //             style: const TextStyle(fontWeight: FontWeight.bold)),
          //         const SizedBox(height: 8),
          //         ClipRRect(
          //           borderRadius: BorderRadius.circular(8),
          //           child: Image.network(
          //             widget.alertScreenshots[index].screenshotUrl,
          //             loadingBuilder: (context, child, progress) {
          //               if (progress == null) return child;
          //               return Center(child: CircularProgressIndicator());
          //             },
          //             errorBuilder: (context, error, stackTrace) {
          //               return Center(
          //                 child: Column(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Icon(Icons.error, size: 64, color: Colors.red),
          //                     Text('Failed to load screenshot'),
          //                     Text(widget.alertScreenshots[index].screenshotUrl, style: TextStyle(fontSize: 12)),
          //                   ],
          //                 ),
          //               );
          //             },
          //           ),
          //         ),
          //         const SizedBox(height: 10),
          //         TextField(
          //           controller: _controllers[index],
          //           decoration: const InputDecoration(
          //             labelText: "Add a description",
          //             border: OutlineInputBorder(),
          //           ),
          //           maxLines: 2,
          //         ),
          //       ],
          //     ),
          //   ),
          // );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.send),
          label: const Text("Send Results"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: controller.sendResults,
        ),
      ),
    );
  }
}
