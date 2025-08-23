import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class ExamMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Exam Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0E21),
        fontFamily: 'Inter',
      ),
      home: ExamMonitoringDashboard(),
    );
  }
}

class ExamMonitoringDashboard extends StatefulWidget {
  @override
  _ExamMonitoringDashboardState createState() =>
      _ExamMonitoringDashboardState();
}

class _ExamMonitoringDashboardState extends State<ExamMonitoringDashboard>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _alertController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _alertAnimation;
  late Animation<double> _fadeAnimation;

  // State variables
  List<Alert> alerts = [];
  List<Student> students = [];
  Timer? _alertTimer;
  Timer? _updateTimer;
  bool isRecording = false;
  int activeViolations = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )
      ..repeat(reverse: true);

    _alertController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _alertAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _alertController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Initialize data
    _initializeStudents();
    _startSimulation();
    _fadeController.forward();
  }

  void _initializeStudents() {
    students = [
      Student(
        id: "STU001",
        name: "Alex Johnson",
        avatar: "👨‍🎓",
        violationCount: 0,
        status: StudentStatus.normal,
        lastScreenshot: "assets/screenshot1.jpg",
      ),
      Student(
        id: "STU002",
        name: "Sarah Chen",
        avatar: "👩‍🎓",
        violationCount: 2,
        status: StudentStatus.warning,
        lastScreenshot: "assets/screenshot2.jpg",
      ),
      Student(
        id: "STU003",
        name: "Mike Wilson",
        avatar: "👨‍🎓",
        violationCount: 5,
        status: StudentStatus.critical,
        lastScreenshot: "assets/screenshot3.jpg",
      ),
    ];
  }

  void _startSimulation() {
    _updateTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (math.Random().nextBool()) {
        _simulateAlert();
      }
      _updateStudentStatus();
    });
  }

  void _simulateAlert() {
    final alertTypes = [
      AlertType.handMovement,
      AlertType.headTurning,
      AlertType.standingUp,
      AlertType.suspiciousSpeech,
      AlertType.multiplePersons,
    ];

    final random = math.Random();
    final alertType = alertTypes[random.nextInt(alertTypes.length)];
    final student = students[random.nextInt(students.length)];

    final alert = Alert(
      id: DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      studentId: student.id,
      studentName: student.name,
      type: alertType,
      timestamp: DateTime.now(),
      confidence: 0.7 + (random.nextDouble() * 0.3),
      description: _getAlertDescription(alertType),
    );

    setState(() {
      alerts.insert(0, alert);
      if (alerts.length > 10) alerts.removeLast();
      activeViolations++;
      student.violationCount++;
      _updateStudentStatus();
    });

    _alertController.forward().then((_) {
      _alertController.reverse();
    });

    HapticFeedback.mediumImpact();
  }

  void _updateStudentStatus() {
    setState(() {
      for (var student in students) {
        if (student.violationCount >= 5) {
          student.status = StudentStatus.critical;
        } else if (student.violationCount >= 2) {
          student.status = StudentStatus.warning;
        } else {
          student.status = StudentStatus.normal;
        }
      }
    });
  }

  String _getAlertDescription(AlertType type) {
    switch (type) {
      case AlertType.handMovement:
        return "Unusual hand movement detected";
      case AlertType.headTurning:
        return "Head turning away from screen";
      case AlertType.standingUp:
        return "Student standing up";
      case AlertType.suspiciousSpeech:
        return "Suspicious speech detected";
      case AlertType.multiplePersons:
        return "Multiple persons in frame";
      default:
        return "Suspicious activity detected";
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _alertController.dispose();
    _fadeController.dispose();
    _alertTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0E21),
                Color(0xFF1D1E33),
                Color(0xFF111328),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _buildMainContent()),
                      Container(width: 1, color: Colors.white10),
                      Expanded(flex: 1, child: _buildSidebar()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.security, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AI Exam Monitor",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Real-time Cheating Detection System",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          Spacer(),
          _buildStatusIndicator(),
          SizedBox(width: 20),
          _buildRecordingButton(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: activeViolations > 3 ? Colors.red :
                  activeViolations > 0 ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (activeViolations > 3 ? Colors.red :
                      activeViolations > 0 ? Colors.orange : Colors.green)
                          .withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(width: 8),
        Text(
          activeViolations > 3 ? "HIGH RISK" :
          activeViolations > 0 ? "MONITORING" : "SECURE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isRecording = !isRecording;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isRecording ? Colors.red : Colors.green,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isRecording ? Colors.red : Colors.green).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRecording ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              isRecording ? "STOP" : "START",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStudentGrid(),
          SizedBox(height: 20),
          _buildOpenPoseVisualization(),
        ],
      ),
    );
  }

  Widget _buildStudentGrid() {
    return Container(
      height: 200,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: students.length,
        itemBuilder: (context, index) {
          return _buildStudentCard(students[index]);
        },
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    Color statusColor;
    IconData statusIcon;

    switch (student.status) {
      case StudentStatus.critical:
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        break;
      case StudentStatus.warning:
        statusColor = Colors.orange;
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1D1E33),
            Color(0xFF2A2D47),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  student.avatar,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        student.id,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      // Simulated video feed with pose overlay
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[900],
                        child: Center(
                          child: _buildPoseOverlay(),
                        ),
                      ),
                      // Status overlay
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6,
                              vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${student.violationCount}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoseOverlay() {
    return CustomPaint(
      size: Size(60, 80),
      painter: PosePainter(),
    );
  }

  Widget _buildOpenPoseVisualization() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1D1E33),
              Color(0xFF2A2D47),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "OpenPose Real-time Analysis",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "ACTIVE",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Stack(
                    children: [
                      // Main pose visualization
                      Center(
                        child: CustomPaint(
                          size: Size(200, 300),
                          painter: DetailedPosePainter(),
                        ),
                      ),
                      // Keypoint indicators
                      Positioned(
                        top: 16,
                        left: 16,
                        child: _buildKeypointLegend(),
                      ),
                      // Analysis metrics
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: _buildAnalysisMetrics(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypointLegend() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Keypoints",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildKeypointItem("Head", Colors.blue),
          _buildKeypointItem("Shoulders", Colors.green),
          _buildKeypointItem("Arms", Colors.orange),
          _buildKeypointItem("Hands", Colors.red),
        ],
      ),
    );
  }

  Widget _buildKeypointItem(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisMetrics() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Analysis",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _buildMetricItem("Confidence", "94.2%"),
          _buildMetricItem("FPS", "30"),
          _buildMetricItem("Latency", "12ms"),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: Color(0xFF111328),
      child: Column(
        children: [
          _buildAlertsPanel(),
          _buildScreenshotsPanel(),
        ],
      ),
    );
  }

  Widget _buildAlertsPanel() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  "Live Alerts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${alerts.length}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  return _buildAlertCard(alerts[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(Alert alert, int index) {
    return AnimatedBuilder(
      animation: _alertAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: index == 0 ? _alertAnimation.value : 1.0,
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getAlertColor(alert.type).withOpacity(0.2),
                  _getAlertColor(alert.type).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getAlertColor(alert.type).withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getAlertIcon(alert.type),
                      color: _getAlertColor(alert.type),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert.studentName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "${(alert.confidence * 100).toInt()}%",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  alert.description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTime(alert.timestamp),
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScreenshotsPanel() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  "Evidence",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return _buildScreenshotCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[800],
              child: Icon(
                Icons.image,
                color: Colors.white30,
                size: 24,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${DateTime
                    .now()
                    .hour}:${DateTime
                    .now()
                    .minute
                    .toString()
                    .padLeft(2, '0')}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.handMovement:
        return Colors.orange;
      case AlertType.headTurning:
        return Colors.yellow;
      case AlertType.standingUp:
        return Colors.red;
      case AlertType.suspiciousSpeech:
        return Colors.purple;
      case AlertType.multiplePersons:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.handMovement:
        return Icons.pan_tool;
      case AlertType.headTurning:
        return Icons.rotate_90_degrees_ccw;
      case AlertType.standingUp:
        return Icons.accessibility;
      case AlertType.suspiciousSpeech:
        return Icons.mic;
      case AlertType.multiplePersons:
        return Icons.group;
      default:
        return Icons.warning;
    }
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString()
        .padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }
}

class PosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Head
    paint.color = Colors.blue;
    canvas.drawCircle(Offset(center.dx, center.dy - 25), 8, paint);

    // Body
    paint.color = Colors.green;
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy + 15),
      paint..style = PaintingStyle.stroke,
    );

    // Arms
    paint.color = Colors.orange;
    canvas.drawLine(
      Offset(center.dx, center.dy - 5),
      Offset(center.dx - 15, center.dy + 5),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 5),
      Offset(center.dx + 15, center.dy + 5),
      paint,
    );

    // Legs
    paint.color = Colors.red;
    canvas.drawLine(
      Offset(center.dx, center.dy + 15),
      Offset(center.dx - 10, center.dy + 30),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 15),
      Offset(center.dx + 10, center.dy + 30),
      paint,
    );

    // Keypoints
    paint.style = PaintingStyle.fill;
    final keypoints = [
      Offset(center.dx, center.dy - 25), // Head
      Offset(center.dx, center.dy - 15), // Neck
      Offset(center.dx - 8, center.dy - 5), // Left shoulder
      Offset(center.dx + 8, center.dy - 5), // Right shoulder
      Offset(center.dx - 15, center.dy + 5), // Left hand
      Offset(center.dx + 15, center.dy + 5), // Right hand
      Offset(center.dx, center.dy + 15), // Hip
      Offset(center.dx - 10, center.dy + 30), // Left foot
      Offset(center.dx + 10, center.dy + 30), // Right foot
    ];

    paint.color = Colors.white;
    for (final point in keypoints) {
      canvas.drawCircle(point, 3, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DetailedPosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    // Head
    paint.color = Colors.blue;
    canvas.drawCircle(Offset(center.dx, center.dy - 60), 20, paint);

    // Neck to shoulders
    paint.color = Colors.green;
    canvas.drawLine(
      Offset(center.dx, center.dy - 40),
      Offset(center.dx, center.dy - 20),
      paint,
    );

    // Shoulders
    canvas.drawLine(
      Offset(center.dx - 30, center.dy - 20),
      Offset(center.dx + 30, center.dy - 20),
      paint,
    );

    // Arms
    paint.color = Colors.orange;
    // Left arm
    canvas.drawLine(
      Offset(center.dx - 30, center.dy - 20),
      Offset(center.dx - 40, center.dy + 10),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - 40, center.dy + 10),
      Offset(center.dx - 35, center.dy + 40),
      paint,
    );

    // Right arm
    canvas.drawLine(
      Offset(center.dx + 30, center.dy - 20),
      Offset(center.dx + 40, center.dy + 10),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + 40, center.dy + 10),
      Offset(center.dx + 35, center.dy + 40),
      paint,
    );

    // Torso
    paint.color = Colors.cyan;
    canvas.drawLine(
      Offset(center.dx, center.dy - 20),
      Offset(center.dx, center.dy + 30),
      paint,
    );

    // Hips
    canvas.drawLine(
      Offset(center.dx - 20, center.dy + 30),
      Offset(center.dx + 20, center.dy + 30),
      paint,
    );

    // Legs
    paint.color = Colors.red;
    // Left leg
    canvas.drawLine(
      Offset(center.dx - 20, center.dy + 30),
      Offset(center.dx - 25, center.dy + 70),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - 25, center.dy + 70),
      Offset(center.dx - 20, center.dy + 100),
      paint,
    );

    // Right leg
    canvas.drawLine(
      Offset(center.dx + 20, center.dy + 30),
      Offset(center.dx + 25, center.dy + 70),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + 25, center.dy + 70),
      Offset(center.dx + 20, center.dy + 100),
      paint,
    );

    // Draw keypoints with different colors
    paint.style = PaintingStyle.fill;
    final keypoints = [
      (Offset(center.dx, center.dy - 60), Colors.blue), // Head
      (Offset(center.dx, center.dy - 40), Colors.lightBlue), // Neck
      (Offset(center.dx - 30, center.dy - 20), Colors.green), // Left shoulder
      (Offset(center.dx + 30, center.dy - 20), Colors.green), // Right shoulder
      (Offset(center.dx - 40, center.dy + 10), Colors.orange), // Left elbow
      (Offset(center.dx + 40, center.dy + 10), Colors.orange), // Right elbow
      (Offset(center.dx - 35, center.dy + 40), Colors.deepOrange), // Left hand
      (Offset(center.dx + 35, center.dy + 40), Colors.deepOrange), // Right hand
      (Offset(center.dx, center.dy + 30), Colors.cyan), // Hip center
      (Offset(center.dx - 20, center.dy + 30), Colors.purple), // Left hip
      (Offset(center.dx + 20, center.dy + 30), Colors.purple), // Right hip
      (Offset(center.dx - 25, center.dy + 70), Colors.red), // Left knee
      (Offset(center.dx + 25, center.dy + 70), Colors.red), // Right knee
      (Offset(center.dx - 20, center.dy + 100), Colors.pink), // Left foot
      (Offset(center.dx + 20, center.dy + 100), Colors.pink), // Right foot
    ];

    for (final (point, color) in keypoints) {
      paint.color = color;
      canvas.drawCircle(point, 6, paint);
      // Add glow effect
      paint.color = color.withOpacity(0.3);
      canvas.drawCircle(point, 12, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Data Models
enum AlertType {
  handMovement,
  headTurning,
  standingUp,
  suspiciousSpeech,
  multiplePersons,
}

enum StudentStatus {
  normal,
  warning,
  critical,
}

class Alert {
  final String id;
  final String studentId;
  final String studentName;
  final AlertType type;
  final DateTime timestamp;
  final double confidence;
  final String description;

  Alert({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.type,
    required this.timestamp,
    required this.confidence,
    required this.description,
  });
}

class Student {
  final String id;
  final String name;
  final String avatar;
  int violationCount;
  StudentStatus status;
  final String lastScreenshot;

  Student({
    required this.id,
    required this.name,
    required this.avatar,
    required this.violationCount,
    required this.status,
    required this.lastScreenshot,
  });
}