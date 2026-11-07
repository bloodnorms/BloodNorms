// ============================================================================
// BloodNorms | blood_banks_stock_view.dart
// Blood Centers Directory & Interactive 8-Group Stock Matrix with Steppers
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';

class BloodBanksStockView extends StatelessWidget {
  final String subPage; // 'banks_directory' | 'banks_stock'
  final List<BloodBankModel> banksList;
  final Map<String, int> stockMatrix;
  final void Function(String group, int delta) onAdjustStock;

  const BloodBanksStockView({
    super.key,
    required this.subPage,
    required this.banksList,
    required this.stockMatrix,
    required this.onAdjustStock,
  });

  @override
  Widget build(BuildContext context) {
    if (subPage == 'banks_directory') {
      return _buildBanksDirectoryPage();
    }
    return _buildBanksStockPage();
  }

  Widget _buildBanksDirectoryPage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connected Blood Center Facilities', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...banksList.map((b) => ListTile(
                dense: true,
                leading: const Icon(Icons.local_hospital_rounded, color: BrandColors.red),
                title: Text(b.name, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('${b.address}, ${b.city} · ${b.is24x7 ? "24x7 Emergency" : "Standard"} · Trust: ${b.trustScore}'),
                trailing: Text('${b.stockUnits} units', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: BrandColors.green)),
              )),
        ],
      ),
    );
  }

  Widget _buildBanksStockPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interactive 8-Group Realtime Stock Matrix', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, fontSize: 17)),
                  Text('Tap + and - buttons to adjust units in real-time. Changes persist live to Supabase.', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 12, color: BrandColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: BrandColors.greenTint, borderRadius: BorderRadius.circular(999)),
                child: Text('${stockMatrix.values.fold(0, (a, b) => a + b)} TOTAL UNITS', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: BrandColors.green, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: stockMatrix.entries.map((e) {
              final group = e.key;
              final units = e.value;

              return Container(
                width: 150,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: BrandColors.red, borderRadius: BorderRadius.circular(6)),
                      child: Text(group, style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    ),
                    const SizedBox(height: 8),
                    Text('$units', style: const TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: BrandColors.textPrimary)),
                    const Text('Available Units', style: TextStyle(fontFamily: BrandTypography.fontFamily, fontSize: 10, color: BrandColors.textSecondary)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: BrandColors.red, size: 22),
                          onPressed: () => onAdjustStock(group, -1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: BrandColors.green, size: 22),
                          onPressed: () => onAdjustStock(group, 1),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
