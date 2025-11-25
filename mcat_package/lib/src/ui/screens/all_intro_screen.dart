import 'package:flutter/material.dart';
import '../../domain/models/mcat_task.dart';
import '../widgets/header_bar.dart';

class AllIntroScreen extends StatelessWidget {
  final VoidCallback? onStart;
  final List<McatTask> tasks;
  const AllIntroScreen({
    super.key,
    required this.onStart,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FB);
    const primaryBlue = Color(0xFF0077B6);
    const warningYellow = Color(0xFFFFF4B8);

    return Scaffold(
      backgroundColor: background,
      appBar: const HeaderBar(title: 'Welcome to mCAT', activeStep: 1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar ---------------------------------------------------------

            // Welcome text ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 8),
                  Text(
                    'Welcome to mCAT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You can pause between the task but not during the task.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Yellow info banner ----------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: warningYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have to complete the word task first !',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Task list -------------------------------------------------------
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  McatTaskCard(
                    icon: Icons.face_3_rounded,
                    iconBackground: primaryBlue,
                    title: 'Face Task',
                    statusLabel: 'Start',
                    statusColor: primaryBlue,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/face_intro',
                      );
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.bookmark_rounded,
                    iconBackground: primaryBlue,
                    title: 'Word Task',
                    statusLabel: 'Completed',
                    statusColor: primaryBlue,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/word_intro',
                      );
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.text_fields_rounded,
                    iconBackground: primaryBlue,
                    title: 'Letter Number Task',
                    statusLabel: 'Start',
                    statusColor: primaryBlue,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/ln_instruction',
                      );
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.markunread_mailbox_rounded,
                    iconBackground: primaryBlue,
                    title: 'Organizational Task',
                    statusLabel: 'Start',
                    statusColor: primaryBlue,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/organizational_intro',
                      );
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.bookmarks_outlined,
                    iconBackground: primaryBlue,
                    title: 'Word Recall Task',
                    statusLabel: 'Completed',
                    statusColor: primaryBlue,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/word_recall_intro',
                      );
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.grid_view_rounded,
                    iconBackground: primaryBlue,
                    title: 'Codding Task',
                    statusLabel: 'Start',
                    statusColor: primaryBlue,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/coding_intro',
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

class _CompletionChip extends StatelessWidget {
  final double percent;
  final Color color;

  const _CompletionChip({
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final label = '${percent.toStringAsFixed(2)}% Completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class McatTaskCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onPressed;

  const McatTaskCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconBackground,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              backgroundColor: statusColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(0, 0),
            ),
            onPressed: onPressed,
            child: Text(
              statusLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
