// ============================================================================
// BloodNorms | bank_inventory_card.dart
// Card component displaying blood bank stock, distance, trust score, and call CTA
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/progress_meter.dart';

class BankInventoryCard extends StatelessWidget {
  final BloodBankModel bank;
  final bool isHighlighted;
  final VoidCallback onCall;

  const BankInventoryCard({
    super.key,
    required this.bank,
    this.isHighlighted = false,
    required this.onCall,
  });

  Widget _buildPill(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(BrandColors.radiusPill),
        border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = bank.distanceMeters / 1000.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandColors.radiusCard),
        border: Border.all(
          color: isHighlighted ? BrandColors.primaryAction : BrandColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressMeter.stockFreshness(
                units: bank.unitsAvailable,
                freshness: bank.stockFreshness,
                size: 58,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.name,
                      style: BrandTypography.title3(color: BrandColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bank.address,
                      style: BrandTypography.caption(color: BrandColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildPill('${distanceKm.toStringAsFixed(1)} km', BrandColors.textPrimary, BrandColors.surfaceSoft),
                        _buildPill('Trust: ${bank.trustScore}', BrandColors.statusError, BrandColors.statusErrorTint),
                        if (bank.isOpen24x7)
                          _buildPill('24x7 OPEN', BrandColors.statusSuccess, BrandColors.statusSuccessTint),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppPillButton(
            label: 'Call Blood Bank',
            icon: Icons.phone_outlined,
            height: 40,
            variant: AppPillButtonVariant.secondary,
            isFullWidth: true,
            onPressed: onCall,
          ),
        ],
      ),
    );
  }
}
