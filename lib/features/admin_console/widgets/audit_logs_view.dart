// ============================================================================
// BloodNorms | audit_logs_view.dart
// Modern Minimal Cryptographically Logged Audit Feed View
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit log ledger',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Append-only cryptographic security audit trail',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 13,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                ),
                child: Text(
                  '${auditLogs.length} events',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: BrandColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...auditLogs.map((log) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: BrandColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BrandColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: Text(
                        log['time'] ?? 'Recent',
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: BrandColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log['action'] ?? 'action',
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: BrandColors.textPrimary,
                            ),
                          ),
                          Text(
                            log['detail'] ?? '',
                            style: const TextStyle(
                              fontFamily: BrandTypography.fontFamily,
                              fontSize: 12,
                              color: BrandColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
