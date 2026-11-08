// ============================================================================
// BloodNorms | stock_tab_view.dart
// Blood Bank Console: Stock Management Tab with 8-group steppers
// ============================================================================

import 'package:flutter/material.dart';
import '../../../shared/constants/blood_groups.dart';
import '../../../shared/theme/brand_colors.dart';
import '../../../shared/theme/brand_typography.dart';
import '../../../shared/widgets/app_pill_button.dart';
import '../../../shared/widgets/notification_bell.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../../shared/widgets/segmented_picker.dart';
import '../../../shared/widgets/speech_bubble.dart';
import 'bank_stock_group_tile.dart';

class StockTabView extends StatelessWidget {
  final String selectedBankName;
  final BloodComponentType selectedComponent;
  final Map<BloodGroup, int> stock;
  final bool isSavingStock;
  final VoidCallback onRefreshUnchanged;
  final VoidCallback onShowBankSelector;
  final ValueChanged<BloodComponentType> onComponentChanged;
  final void Function(BloodGroup group) onIncrement;
  final void Function(BloodGroup group) onDecrement;
  final VoidCallback onSaveStock;

  const StockTabView({
    super.key,
    required this.selectedBankName,
    required this.selectedComponent,
    required this.stock,
    required this.isSavingStock,
    required this.onRefreshUnchanged,
    required this.onShowBankSelector,
    required this.onComponentChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSaveStock,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.surfaceSoft,
      appBar: ScreenHeader(
        title: 'Stock Management',
        showBackButton: true,
        trailing: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRefreshUnchanged,
              borderRadius: BorderRadius.circular(BrandColors.radiusPill),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BrandColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                  border: Border.all(color: BrandColors.borderSubtle, width: 1.0),
                ),
                child: const Text(
                  'ALL SAME',
                  style: TextStyle(
                    fontFamily: BrandTypography.fontFamily,
                    color: BrandColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const NotificationBell(role: 'bank_staff'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const SpeechBubble(
                    emoji: '🩸',
                    text: "Keep units accurate. When blood bank stock is truthful, families don't waste hours on the road.",
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: onShowBankSelector,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  selectedBankName,
                                  style: BrandTypography.title2(color: BrandColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down_rounded, color: BrandColors.textPrimary, size: 24),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BrandColors.statusSuccessTint,
                          borderRadius: BorderRadius.circular(BrandColors.radiusPill),
                          border: Border.all(color: BrandColors.statusSuccess.withValues(alpha: 0.3), width: 1.0),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle_outline_rounded, size: 14, color: BrandColors.statusSuccess),
                            SizedBox(width: 4),
                            Text(
                              'Updated 25m ago',
                              style: TextStyle(
                                fontFamily: BrandTypography.fontFamily,
                                color: BrandColors.statusSuccess,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SegmentedPicker<BloodComponentType>(
                    items: const [
                      SegmentItem(value: BloodComponentType.wholeBlood, label: 'Whole'),
                      SegmentItem(value: BloodComponentType.redCells, label: 'Red cells'),
                      SegmentItem(value: BloodComponentType.platelets, label: 'Platelets'),
                      SegmentItem(value: BloodComponentType.plasma, label: 'Plasma'),
                    ],
                    selectedValue: selectedComponent,
                    activeColor: BrandColors.primaryAction,
                    onValueChanged: onComponentChanged,
                  ),
                  const SizedBox(height: 18),
                  ...BloodGroup.values.map(
                    (group) => BankStockGroupTile(
                      group: group,
                      currentUnits: stock[group] ?? 0,
                      onIncrement: () => onIncrement(group),
                      onDecrement: () => onDecrement(group),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: BrandColors.background,
                border: Border(top: BorderSide(color: BrandColors.borderSubtle, width: 1.0)),
              ),
              child: SafeArea(
                top: false,
                child: AppPillButton(
                  label: 'Save Stock',
                  variant: AppPillButtonVariant.primary,
                  isLoading: isSavingStock,
                  isFullWidth: true,
                  onPressed: onSaveStock,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
