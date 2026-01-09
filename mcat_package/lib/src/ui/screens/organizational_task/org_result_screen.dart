import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import '../../widgets/header_bar.dart';
import '../../../domain/models/organizational_models.dart';
import 'package:mcat_package/src/services/data_service.dart';

class OrgResultScreen extends StatelessWidget {
  final OrgController controller;
  final VoidCallback? onNextTask;

  const OrgResultScreen({super.key, required this.controller, this.onNextTask});

  Map<String, dynamic> _getDeviceData(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final isTouchDevice = isMobile;

    return {
      'isiPad': Platform.isIOS && MediaQuery.of(context).size.width > 768,
      'isMobile': isMobile,
      'osVersion': _getOSVersion(),
      'userAgent': _getUserAgent(),
      'isTouchDevice': isTouchDevice,
      'possibleDeviceType': _getDeviceType(context),
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
    return 'MCAT_App/${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  }

  String _getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ratio = MediaQuery.of(context).devicePixelRatio;
    final width = size.width * ratio;

    if (Platform.isIOS && width > 768) return 'tablet';
    if (Platform.isAndroid && width > 600) return 'tablet';
    if (Platform.isIOS || Platform.isAndroid) return 'phone';
    return 'desktop';
  }

  Future<void> saveState(BuildContext context) async {
    final total = controller.totalRounds;
    final score = controller.correctCount;
    final deviceData = _getDeviceData(context);

    await DataService().saveTask('organizational_task_final', {
      'sequenceId': 0,
      'studyDeploymentId': '', // Add your study deployment ID
      'deviceRoleName': 'ICAT Mobile App',
      'measurement': {
        'sensorStartTime': DateTime.now().millisecondsSinceEpoch,
        'data': {
          'task': 'WAISL',
          'score': score,
          '__type': 'dk.cachet.icat.waisl',
          'total_trials': total,
          'accuracy': score / total,
          'deviceData': deviceData,
        }
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = controller.totalRounds;
    final score = controller.correctCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: const HeaderBar(title: 'Organizational Result', activeStep: 4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('Your score',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('$score / $total',
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            '${((score / total) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              color: (score / total) >= 0.7
                                  ? Colors.green
                                  : (score / total) >= 0.5
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                saveState(context);
                if (onNextTask != null) {
                  onNextTask!();
                } else {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFFFFFFFF),
                backgroundColor: const Color(0xFF006BA6),
              ),
              child: const Text('Done'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
