// ============================================================================
// BloodNorms | data_export_result_dialog.dart
// Dialog displaying generated CSV data export with clipboard copy action
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

void showDataExportResultDialog({
  required BuildContext context,
  required String filename,
  required String watermarkHash,
  required String csvContent,
  required void Function(String message) onShowToast,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: BrandColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandColors.radiusDialog),
        side: const BorderSide(color: BrandColors.borderSubtle, width: 1.0),
      ),
      title: const Text(
        'Export generated (CSV)',
        style: TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: $filename', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Watermark: $watermarkHash', style: const TextStyle(fontSize: 12, color: BrandColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BrandColors.surfaceSoft,
                borderRadius: BorderRadius.circular(BrandColors.radiusInput),
                border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
              ),
              child: Text(
                csvContent,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppPillButton(
          label: 'Copy CSV',
          variant: AppPillButtonVariant.secondary,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: csvContent));
            Navigator.pop(ctx);
            onShowToast('CSV contents copied to clipboard!');
          },
        ),
        const SizedBox(width: 8),
        AppPillButton(
          label: 'Close',
          variant: AppPillButtonVariant.primary,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}

