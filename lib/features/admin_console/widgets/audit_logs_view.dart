// ============================================================================
// BloodNorms | audit_logs_view.dart
// Cryptographically Logged Audit Feed View (DPDP Section 0.3 Compliance)
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class AuditLogsView extends StatelessWidget {
  final List<Map<String, dynamic>> auditLogs;

  const AuditLogsView({
    super.key,
    required this.auditLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cryptographically Logged Audit Feed',
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                '${auditLogs.length} Events',
                style: const TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 12,
                  color: BrandColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...auditLogs.map((log) => ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    log['time'] ?? 'Recent',
                    style: const TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ),
                title: Text(
                  log['action'] ?? 'action',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: BrandColors.red,
                  ),
                ),
                subtitle: Text(
                  log['detail'] ?? '',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 12,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
