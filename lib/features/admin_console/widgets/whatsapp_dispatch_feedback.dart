// ============================================================================
// BloodNorms | whatsapp_dispatch_feedback.dart
// Status Feedback Banner for WhatsApp Cloud API Dispatch Operations
// ============================================================================

import 'package:flutter/material.dart';

class WhatsAppDispatchFeedback extends StatelessWidget {
  final bool isWaSending;
  final bool? lastDispatchSuccess;
  final String? lastDispatchStatus;
  final String? lastMessageId;
  final String? lastErrorDetails;

  const WhatsAppDispatchFeedback({
    super.key,
    required this.isWaSending,
    required this.lastDispatchSuccess,
    required this.lastDispatchStatus,
    required this.lastMessageId,
    required this.lastErrorDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (isWaSending) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF25D366),
              ),
            ),
            SizedBox(width: 12),
            Text('Connecting to Meta Graph API v19.0 and dispatching message...'),
          ],
        ),
      );
    }

    if (lastDispatchSuccess == true) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Text(
          '✓ Message accepted by Meta! Message ID: ${lastMessageId ?? "Confirmed"}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF166534),
          ),
        ),
      );
    }

    if (lastDispatchSuccess == false) {
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Text(
          '✕ Failed (HTTP ${lastDispatchStatus ?? "ERR"}): ${lastErrorDetails ?? "Unknown error"}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF991B1B),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
