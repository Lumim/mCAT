import 'package:flutter/material.dart';

class McatHomeScreen extends StatelessWidget {
  const McatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5F6FA);
    const primaryBlue = Color(0xFF0077B6);
    const warningYellow = Color(0xFFFFF4B8);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // CARP logo (simple placeholder)
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.videocam_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CARP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Progress pill
                  _CompletionChip(
                    percent: 16.33,
                    color: primaryBlue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // TODO: Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),

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
                      // TODO: open Face Task
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.bookmark_rounded,
                    iconBackground: primaryBlue,
                    title: 'Word Task',
                    statusLabel: 'Completed',
                    statusColor: primaryBlue,
                    onPressed: () {
                      // TODO: open Word Task (maybe review)
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.text_fields_rounded,
                    iconBackground: primaryBlue,
                    title: 'Letter Number Task',
                    statusLabel: 'Start',
                    statusColor: primaryBlue,
                    onPressed: () {
                      // TODO: open Letter Number Task
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.markunread_mailbox_rounded,
                    iconBackground: primaryBlue,
                    title: 'Organizational Task',
                    statusLabel: 'Start',
                    statusColor: primaryBlue,
                    onPressed: () {
                      // TODO: open Organizational Task
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.bookmarks_outlined,
                    iconBackground: primaryBlue,
                    title: 'Word Recall Task',
                    statusLabel: 'Completed',
                    statusColor: primaryBlue,
                    onPressed: () {
                      // TODO: open Word Recall Task
                    },
                  ),
                  McatTaskCard(
                    icon: Icons.grid_view_rounded,
                    iconBackground: primaryBlue,
                    title: 'Face Task',
                    statusLabel: 'Start',
                    statusColor: primaryBlue,
                    onPressed: () {
                      // TODO: open second Face Task
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
