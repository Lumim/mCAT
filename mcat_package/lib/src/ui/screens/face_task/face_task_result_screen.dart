import 'package:flutter/material.dart';
import '../../widgets/header_bar.dart';
import '../../widgets/primary_button.dart';

class FaceTaskResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onNext;

  const FaceTaskResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // disable back navigation
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FB),
        appBar: const HeaderBar(
          title: 'Face Task',
          activeStep: 2, // step indicator highlights step 2
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // --- Score Card ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'You have scored $score out of $total in the Face Task!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // --- Green confirmation button ---
              /*              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'Answer submitted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ), */

              const Spacer(),

              // --- Next button ---
              PrimaryButton(
                label: 'Next',
                onPressed: onNext,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
