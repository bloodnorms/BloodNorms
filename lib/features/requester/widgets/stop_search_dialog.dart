// ============================================================================
// BloodNorms | stop_search_dialog.dart
// Confirmation dialog to cancel an active emergency blood request
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../providers/request_flow_provider.dart';

void showStopEmergencySearchDialog({
  required BuildContext context,
  required String reqId,
  required VoidCallback onSearchStopped,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: BrandColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
        side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
      ),
      title: Text(
        'Stop Search?',
        style: BrandTypography.title2(color: BrandColors.statusError),
      ),
      content: Text(
        'This will cancel the active request in Supabase and notify contacted donors that blood is no longer needed.',
        style: BrandTypography.body(color: BrandColors.textSecondary),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppPillButton(
                text: 'Keep Searching',
                variant: AppPillButtonVariant.secondary,
                height: 44,
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppPillButton(
                text: 'Stop',
                variant: AppPillButtonVariant.destructive,
                height: 44,
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
                        backgroundColor: BrandColors.statusError,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
