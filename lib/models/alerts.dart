// Alert model
class Alert {
  String pid;
  String reason;
  String decision;
  String? description;
  String screenshotUrl;
  double timestamp;

  Alert({
    required this.pid,
    required this.reason,
    required this.decision,
    required this.screenshotUrl,
    required this.timestamp,
    this.description,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      pid: json['pid'] ?? '',
      reason: json['reason'] ?? '',
      decision: json['decision'] ?? '',
      screenshotUrl: json['screenshot_url'] ?? '',
      description: json['description'] ?? '',
      timestamp: (json['timestamp'] ?? 0).toDouble(),
    );
  }

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
}
