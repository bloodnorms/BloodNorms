// ============================================================================
// BloodNorms | closed_request_banner.dart
// Status banner showing a recently closed or fulfilled request
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

class ClosedRequestBanner extends StatelessWidget {
  final Map<String, dynamic> activeRequest;
  final VoidCallback onDismiss;

  const ClosedRequestBanner({
    super.key,
    required this.activeRequest,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = activeRequest['status'] == 'cancelled';
    final hospital = activeRequest['hospital_name']?.toString() ?? 'Hospital';
    final outcome = activeRequest['outcome']?.toString() ??
        (isCancelled ? 'Cancelled' : 'Completed');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCancelled ? const Color(0xFFE52E2E) : const Color(0xFF10B981),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCancelled
                ? Icons.cancel_outlined
                : Icons.check_circle_outline_rounded,
            color: isCancelled
                ? const Color(0xFFE52E2E)
                : const Color(0xFF10B981),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCancelled
                      ? 'Previous Request Cancelled'
                      : 'Previous Request Fulfilled',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCancelled
                        ? const Color(0xFFE52E2E)
                        : const Color(0xFF10B981),
                  ),
                ),
                Text(
                  '$hospital ($outcome)',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 11.5,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDismiss,
            child: const Text(
              'DISMISS',
              style: TextStyle(
                fontFamily: BrandTypography.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
