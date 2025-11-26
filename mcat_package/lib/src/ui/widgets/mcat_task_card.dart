// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

class McatTaskCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String statusLabel;
  final Color statusColor;
  final String? subtitle;
  final bool enabled;
  final VoidCallback onPressed;

  const McatTaskCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    this.subtitle,
    this.enabled = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        enabled ? statusColor : Colors.grey.shade300; // disabled look

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              backgroundColor: bgColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(0, 0),
            ),
            onPressed: enabled ? onPressed : null,
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
