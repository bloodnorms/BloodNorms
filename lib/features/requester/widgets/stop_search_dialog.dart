// ============================================================================
// BloodNorms | stop_search_dialog.dart
// Confirmation dialog to cancel an active emergency blood request
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_typography.dart';
import '../providers/request_flow_provider.dart';

void showStopEmergencySearchDialog({
  required BuildContext context,
  required String reqId,
  required VoidCallback onSearchStopped,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE52E2E), width: 2.0),
      ),
      title: const Text(
        'Stop Search?',
        style: TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE52E2E),
        ),
      ),
      content: const Text(
        'This will cancel the active request in Supabase and notify contacted donors that blood is no longer needed.',
        style: TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontSize: 14,
          color: Color(0xFF4B5563),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'KEEP SEARCHING',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await SupabaseService().closeRequest(
                    reqId,
                    outcome: 'cancelled_by_requester',
                    status: 'cancelled',
                  );
                  globalRequestFlow.clearActiveRequestId();
                  onSearchStopped();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Active blood request cancelled.'),
                        backgroundColor: Color(0xFFE52E2E),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE52E2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'STOP',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
