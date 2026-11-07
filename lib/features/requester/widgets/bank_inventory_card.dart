// ============================================================================
// BloodNorms | bank_inventory_card.dart
// Card component displaying blood bank stock, distance, trust score, and call CTA
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/models/blood_bank_model.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/action_button.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BrandColors.border, width: 1.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: BrandTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distanceKm = bank.distanceMeters / 1000.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted ? BrandColors.red : BrandColors.border,
          width: isHighlighted ? 2.5 : 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: BrandColors.border,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
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
                size: 64,
              ),
              const SizedBox(width: 16),
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
                        _buildPill('${distanceKm.toStringAsFixed(1)} km', BrandColors.textPrimary, const Color(0xFFF0F0F0)),
                        _buildPill('Trust: ${bank.trustScore}', BrandColors.red, BrandColors.redTint),
                        if (bank.isOpen24x7)
                          _buildPill('24x7 OPEN', BrandColors.green, BrandColors.greenTint),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ActionButton(
            label: 'CALL BLOOD BANK',
            icon: Icons.phone_rounded,
            height: 44,
            variant: ActionButtonVariant.success,
            onPressed: onCall,
          ),
        ],
      ),
    );
  }
}
