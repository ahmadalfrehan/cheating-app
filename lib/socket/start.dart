import 'package:cheating_detection/getx/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Start extends StatelessWidget {
  Start({super.key});

  final controller = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cheating Detection Monitor'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: controller.title,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: controller.periodM,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: const InputDecoration(
                labelText: "Period",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: controller.description,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            // Text('Period'),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     SizedBox(
            //       width: 80,
            //       child: TimeInputField(controller: controller.periodH
            //           , hintText: "HH", maxValue: 23),
            //     ),
            //     SizedBox(width: 12),
            //     SizedBox(
            //       width: 80,
            //       child: TimeInputField(controller:
            //       controller.periodM, hintText: "MM", maxValue: 59),
            //     ),
            //   ],
            // ),
            Spacer(),
            Obx(() =>
            controller.isLoading.value
                ? CircularProgressIndicator()
                :
            ElevatedButton(onPressed: () {
              controller.createExam();
            }, child: Text('Start Exam')),
            )
          ],
        ),
      ),
    );
  }
}

class TimeInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final int maxValue; // 23 for hours, 59 for minutes

  const TimeInputField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2), // max 2 digits
        _MaxValueTextInputFormatter(maxValue),
      ],
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // rounded border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Custom formatter to enforce max value (like 23 hours or 59 minutes)
class _MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;

  _MaxValueTextInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final int? value = int.tryParse(newValue.text);
    if (value == null || value > maxValue) {
      return oldValue; // reject invalid input
    }
    return newValue;
  }
}
