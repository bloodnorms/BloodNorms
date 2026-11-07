// ============================================================================
// BloodNorms | language_picker_sheet.dart
// Language selection bottom modal sheet for English, Telugu, and Hindi
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_typography.dart';

void showLanguagePickerModal(
  BuildContext context, {
  required ValueChanged<Locale> onLocaleChanged,
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
          const Text(
            'Choose Language / భాష / भाषा',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _buildLangTile(ctx, 'English', const Locale('en'), onLocaleChanged),
          const SizedBox(height: 8),
          _buildLangTile(
            ctx,
            'తెలుగు (Telugu)',
            const Locale('te'),
            onLocaleChanged,
          ),
          const SizedBox(height: 8),
          _buildLangTile(
            ctx,
            'हिंदी (Hindi)',
            const Locale('hi'),
            onLocaleChanged,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLangTile(
  BuildContext ctx,
  String label,
  Locale loc,
  ValueChanged<Locale> onChanged,
) {
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () {
      Navigator.pop(ctx);
      onChanged(loc);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: Color(0xFFE52E2E),
          ),
        ],
      ),
    ),
  );
}
