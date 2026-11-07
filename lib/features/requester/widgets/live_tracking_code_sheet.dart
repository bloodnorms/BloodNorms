// ============================================================================
// BloodNorms | live_tracking_code_sheet.dart
// 6-digit PIN keypad bottom sheet for verifying donor passes
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/pin_keypad.dart';

void showLiveTrackingCodeSheet({
  required BuildContext context,
  required ValueChanged<String> onCodeSubmitted,
}) {
  String enteredCode = '';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: BrandColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Enter Donor Code', style: BrandTypography.title2(color: BrandColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(
                    'Ask the donor for their 6-digit pass code to verify donation',
                    style: BrandTypography.caption(color: BrandColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  CodeDisplayDots(code: enteredCode),
                  const SizedBox(height: 24),
                  PinKeypad(
                    onDigitPressed: (digit) {
                      if (enteredCode.length < 6) {
                        setSheetState(() => enteredCode += digit);
                        if (enteredCode.length == 6) {
                          Navigator.pop(ctx);
                          onCodeSubmitted(enteredCode);
                        }
                      }
                    },
                    onDeletePressed: () {
                      if (enteredCode.isNotEmpty) {
                        setSheetState(() => enteredCode = enteredCode.substring(0, enteredCode.length - 1));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
