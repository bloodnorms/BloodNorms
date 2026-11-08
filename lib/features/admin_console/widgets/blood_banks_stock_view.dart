// ============================================================================
// BloodNorms | blood_banks_stock_view.dart
// Modern Minimal Blood Centers Directory & Interactive 8-Group Stock Matrix
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import 'blood_banks_directory_card.dart';

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
      return BloodBanksDirectoryCard(banksList: banksList);
    }
    return _buildBanksStockPage();
  }

  Widget _buildBanksStockPage() {
    final totalUnits = stockMatrix.values.fold(0, (a, b) => a + b);

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
                    'Interactive 8-group stock matrix',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: BrandColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap + and - to adjust units in real-time with instant persistence',
                    style: TextStyle(
                      fontFamily: BrandTypography.fontFamily,
                      fontSize: 13,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: BrandColors.accentTint,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                ),
                child: Text(
                  '$totalUnits units available',
                  style: const TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.accent,
                    fontSize: 12,
                  ),
                ),
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
                width: 145,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BrandColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(BrandColors.radiusCard),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: BrandColors.background,
                        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                      ),
                      child: Text(
                        group,
                        style: const TextStyle(
                          fontFamily: BrandTypography.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$units',
                      style: const TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Units in stock',
                      style: TextStyle(
                        fontFamily: BrandTypography.fontFamily,
                        fontSize: 11,
                        color: BrandColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                          color: BrandColors.textSecondary,
                          onPressed: () => onAdjustStock(group, -1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                          color: BrandColors.primaryAction,
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
