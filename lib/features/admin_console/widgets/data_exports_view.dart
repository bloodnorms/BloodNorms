// ============================================================================
// BloodNorms | data_exports_view.dart
// Privacy-Governed DPDP Data Exports Desk (SHA-256 Watermarking Engine)
// Neutralizes CSV Formula Injection (CWE-1236) via sanitizeCsvCell
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy-Governed DPDP Data Exports',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Generates SHA-256 watermarked CSV files. Donor health questions are strictly unreadable per Section 0.3.',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontSize: 12,
              color: BrandColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _handleGenerateExport(context),
            icon: const Icon(Icons.file_download_rounded, size: 16),
            label: const Text('Generate Masked Donors CSV Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
            'Export Records on Ledger:',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          ...dataExports.map((e) => ListTile(
                dense: true,
                leading: const Icon(Icons.table_chart_rounded,
                    color: Color(0xFF0891B2)),
                title: Text(
                  e['filename']?.toString() ?? 'export.csv',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                    'SHA-256: ${e['watermark_hash']?.toString().substring(0, 10)}...'),
                trailing: const Text(
                  'READY',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.green,
                    fontSize: 11,
                  ),
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
          title: const Text(
            'Export Generated (CSV)',
            style: TextStyle(
              fontFamily: BrandTypography.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File: ${res['filename']}'),
                Text('Watermark: ${res['watermark_hash']}'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    csvContent,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: csvContent));
                Navigator.pop(ctx);
                onShowToast('CSV contents copied to clipboard!');
              },
              child: const Text('Copy CSV'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
