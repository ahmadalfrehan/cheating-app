import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../getx/controller.dart';
import '../models/alerts.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final bool? description;
  final int? index;

   AlertCard({Key? key, required this.alert, this.description,this.index})
    : super(key: key);

  Color _getAlertColor(String decision) {
    if (decision.contains('Disqualified')) return Colors.red;
    if (decision.contains('Under Review')) return Colors.orange;
    if (decision.contains('Warning')) return Colors.yellow;
    return Colors.green;
  }
  final controller = Get.put(AppController());

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
    return Column(
      children: [
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getAlertColor(alert.decision).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getAlertIcon(alert.reason),
                color: _getAlertColor(alert.decision),
              ),
            ),
            title: Text(
              '${alert.pid} - ${alert.reason.replaceAll('_', ' ').toUpperCase()}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.decision,
                  style: TextStyle(
                    color: _getAlertColor(alert.decision),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Time: ${alert.dateTime.toLocal().toString().split('.')[0]}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),

              ],
            ),
            trailing:
                alert.screenshotUrl.isNotEmpty
                    ? IconButton(
                      icon: Icon(Icons.photo),
                      onPressed:
                          () => _showScreenshot(context, alert.screenshotUrl),
                    )
                    : null,
          ),
        ),
        if (description == true)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              height: 45,
              // width: double.infinity,
              child: TextField(
                onChanged: (value){
                  controller.alerts[index??0].description = value;
                },

                // controller: controller.alerts.value[index],//_controllers[index],
                decoration: const InputDecoration(
                  labelText: "Add a description",
                  border: OutlineInputBorder(),
                ),

                // maxLines: 2,
              ),
            ),
          ),
      ],
    );
  }

  void _showScreenshot(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('Alert Screenshot'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: Image.network(
                  url,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red),
                          Text('Failed to load screenshot'),
                          Text(url, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
