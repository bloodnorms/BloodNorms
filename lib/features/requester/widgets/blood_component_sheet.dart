// ============================================================================
// BloodNorms | blood_component_sheet.dart
// Modal picker allowing requesters to select Whole Blood, Red Cells, Platelets, etc.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

void showBloodComponentPickerSheet({
  required BuildContext context,
  required BloodComponentType selectedComponent,
  required ValueChanged<BloodComponentType> onSelected,
}) {
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
          Text('Select Component', style: BrandTypography.title2(color: BrandColors.textPrimary)),
          const SizedBox(height: 16),
          ...BloodComponentType.values.map((c) {
            final isSel = c == selectedComponent;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Text('🩸', style: TextStyle(fontSize: 22)),
              title: Text(
                c.label,
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: isSel ? BrandColors.red : BrandColors.textPrimary,
                ),
              ),
              trailing: isSel ? const Icon(Icons.check_rounded, color: BrandColors.red) : null,
              onTap: () {
                Navigator.pop(ctx);
                onSelected(c);
              },
            );
          }),
        ],
      ),
    ),
  );
}
