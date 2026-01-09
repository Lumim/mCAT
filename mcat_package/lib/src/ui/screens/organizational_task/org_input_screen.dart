import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';
import 'package:mcat_package/src/services/data_service.dart';

class OrgInputScreen extends StatefulWidget {
  final OrgController controller;
  const OrgInputScreen({super.key, required this.controller});

  @override
  State<OrgInputScreen> createState() => _OrgInputScreenState();
}

class _OrgInputScreenState extends State<OrgInputScreen> {
  final TextEditingController _ctrl = TextEditingController();
  DateTime? _stimuliTime; // Track when stimuli was shown
  DateTime? _responseTime; // Track when user responded

  @override
  void initState() {
    super.initState();
    // Record stimuli time when screen loads (stimuli was shown in play screen)
    _stimuliTime = DateTime.now();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _sanitize(String s) => s.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  Future<void> _saveTrialData(bool isCorrect) async {
    final answer = _sanitize(_ctrl.text);
    final roundNo = widget.controller.roundIndex + 1;

    // Get device data
    final deviceData = _getDeviceData();

    // Save trial data
    await DataService().saveTask('organizational_task_trial$roundNo', {
      'sequenceId': 0,
      'studyDeploymentId': '', // Add your study deployment ID if available
      'deviceRoleName': 'ICAT Mobile App',
      'measurement': {
        'sensorStartTime': DateTime.now().millisecondsSinceEpoch,
        'data': {
          'task': 'WAISL',
          'score': widget.controller.correctCount,
          '__type': 'dk.cachet.icat.waisl',
          'trial$roundNo': {
            'stimuli': widget.controller.current.stimuliElements,
            'response': answer.split(''),
            'stimuli_time': _stimuliTime?.toIso8601String() ??
                DateTime.now().toIso8601String(),
            'response_time': _responseTime?.toIso8601String() ??
                DateTime.now().toIso8601String(),
            'response_type': 'written',
            'is_correct': isCorrect,
          },
          'deviceData': deviceData,
        }
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> _getDeviceData() {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final isTouchDevice = isMobile;

    return {
      'isiPad': Platform.isIOS && MediaQuery.of(context).size.width > 768,
      'isMobile': isMobile,
      'osVersion': _getOSVersion(),
      'userAgent': _getUserAgent(),
      'isTouchDevice': isTouchDevice,
      'possibleDeviceType': _getDeviceType(),
    };
  }

  String _getOSVersion() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'Mac OS X';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  String _getUserAgent() {
    // For mobile apps, we can provide a custom user agent
    String os = Platform.operatingSystem;
    String version = Platform.operatingSystemVersion;
    return 'MCAT_App/$os $version';
  }

  String _getDeviceType() {
    final size = MediaQuery.of(context).size;
    final ratio = MediaQuery.of(context).devicePixelRatio;
    final width = size.width * ratio;

    if (Platform.isIOS && width > 768) return 'tablet';
    if (Platform.isAndroid && width > 600) return 'tablet';
    if (Platform.isIOS || Platform.isAndroid) return 'phone';
    return 'desktop';
  }

  Future<void> _checkAnswer() async {
    final answer = _sanitize(_ctrl.text);
    final correct = widget.controller.current.correctAnswer;
    final ok = answer == correct;

    // Record response time
    _responseTime = DateTime.now();

    // Save trial data
    await _saveTrialData(ok);

    widget.controller.recordCorrect(ok);

    // NO FEEDBACK - immediately go to next
    _next();
  }

  void _next() {
    if (!widget.controller.isLast) {
      widget.controller.nextRound();
      Navigator.pushReplacementNamed(context, '/org_play',
          arguments: widget.controller);
    } else {
      Navigator.pushReplacementNamed(context, '/org_result',
          arguments: widget.controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundNo = widget.controller.roundIndex + 1;
    final total = widget.controller.totalRounds;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: HeaderBar(
          title: 'Organizational Task $roundNo/$total', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the numbers first (ascending), then letters in alphabetical order.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              textAlign: TextAlign.center,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Type and tap Next',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Display current sequence for reference (optional, can remove)
            Text(
              'Sequence: ${widget.controller.current.ttsPhrase}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: _ctrl.text.isEmpty ? null : _checkAnswer,
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              child: const Text('Next'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
