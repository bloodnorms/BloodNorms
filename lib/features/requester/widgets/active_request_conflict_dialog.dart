// ============================================================================
// BloodNorms | active_request_conflict_dialog.dart
// Conflict dialog when user initiates a new emergency while another is active
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/brand_typography.dart';
import '../providers/request_flow_provider.dart';

void showActiveRequestConflictDialog(
  BuildContext context,
  Map<String, dynamic> activeRequest,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Active Search in Progress',
        style: TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
      content: Text(
        'You currently have an active emergency blood search for ${activeRequest['blood_group']} at ${activeRequest['hospital_name']}.\n\nWould you like to continue tracking it, or start a new request?',
        style: const TextStyle(
          fontFamily: BrandTypography.fontFamily,
          color: Color(0xFF4B5563),
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            globalRequestFlow.reset();
            context.push('/group');
          },
          child: const Text(
            'START NEW',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE52E2E),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/live/${activeRequest['id']}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE52E2E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'VIEW ACTIVE',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
