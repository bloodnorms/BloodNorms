// ============================================================================
// BloodNorms | data_exports_view.dart
// Modern Minimal Privacy-Governed DPDP Data Exports Desk
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';

class DataExportsView extends StatelessWidget {
  final List<Map<String, dynamic>> dataExports;
  final void Function(String message) onShowToast;

  const DataExportsView({
    super.key,
    required this.dataExports,
    required this.onShowToast,
  });

  String _buildSanitizedCsv(List<List<String>> rows) {
    final s = SupabaseService();
    return rows
        .map((row) => row.map((cell) => s.sanitizeCsvCell(cell)).join(','))
        .join('\n');
  }

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
          const Text(
            'Privacy-governed data exports',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Generates SHA-256 watermarked CSV files. Donor health answers are strictly excluded.',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 13,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          AppPillButton(
            label: 'Generate masked donors CSV export',
            icon: Icons.file_download_outlined,
            variant: AppPillButtonVariant.primary,
            onPressed: () => _handleGenerateExport(context),
          ),
          const SizedBox(height: 20),
          const Divider(color: BrandColors.borderSubtle),
          const SizedBox(height: 12),
          const Text(
            'Export records on ledger:',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: BrandColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...dataExports.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: BrandColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: BrandColors.accentTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.table_chart_outlined,
                            size: 16,
                            color: BrandColors.accent,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e['filename']?.toString() ?? 'export.csv',
                              style: const TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: BrandColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SHA-256: ${e['watermark_hash']?.toString().substring(0, 10)}...',
                              style: const TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                fontSize: 11,
                                color: BrandColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BrandColors.statusSuccessTint,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                      ),
                      child: const Text(
                        'Ready',
                        style: TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          color: BrandColors.statusSuccess,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _handleGenerateExport(BuildContext context) async {
    final res = await SupabaseService().createDataExport(
      entityType: 'donors',
      tier: '2',
      format: 'csv',
      reason: 'Routine quarterly audit export for health authorities',
    );
    if (res['ok'] == true && context.mounted) {
      final sampleRows = [
        ['id', 'name', 'phone', 'blood_group', 'city'],
        ['#101', 'Suresh M.', '+91******3210', 'O+', 'Rajahmundry'],
        ['#102', 'K. Ravi', '+91******4321', 'B+', 'Rajahmundry'],
      ];
      final csvContent = _buildSanitizedCsv(sampleRows);

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
                Text('File: ${res['filename']}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text('Watermark: ${res['watermark_hash']}', style: const TextStyle(fontSize: 12, color: BrandColors.textSecondary)),
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
  }
}
