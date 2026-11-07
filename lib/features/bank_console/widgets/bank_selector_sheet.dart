// ============================================================================
// BloodNorms | bank_selector_sheet.dart
// Bottom sheet dialog allowing bank staff to switch between blood centers
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

void showBankSelectorSheet({
  required BuildContext context,
  required List<Map<String, dynamic>> banks,
  required String selectedBankId,
  required void Function(String id, String name) onBankSelected,
}) {
  if (banks.isEmpty) return;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Blood Bank', style: BrandTypography.title2(color: BrandColors.textPrimary)),
          const SizedBox(height: 12),
          ...banks.map((b) {
            final id = b['id']?.toString() ?? '';
            final name = b['name']?.toString() ?? 'Blood Bank';
            final isSel = id == selectedBankId;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: isSel ? BrandColors.red : BrandColors.textSecondary,
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: BrandColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onBankSelected(id, name);
              },
            );
          }),
        ],
      ),
    ),
  );
}

